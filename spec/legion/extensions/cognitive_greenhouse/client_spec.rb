# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveGreenhouse::Client do
  subject(:client) { described_class.new }

  describe '#initialize' do
    it 'creates a default greenhouse' do
      expect(client.send(:greenhouse))
        .to be_a(Legion::Extensions::CognitiveGreenhouse::Helpers::Greenhouse)
    end

    it 'accepts a custom greenhouse' do
      custom = Legion::Extensions::CognitiveGreenhouse::Helpers::Greenhouse.new(season: :winter)
      c = described_class.new(greenhouse: custom)
      expect(c.send(:greenhouse).season).to eq(:winter)
    end
  end

  describe '#plant_idea' do
    it 'plants a valid idea' do
      result = client.plant_idea(plant_type: :hypothesis, domain: 'cognition', content: 'idea')
      expect(result[:success]).to be true
    end

    it 'rejects invalid plant type' do
      result = client.plant_idea(plant_type: :invalid, domain: 'd', content: 'c')
      expect(result[:success]).to be false
    end
  end

  describe '#tend_greenhouse' do
    before { client.plant_idea(plant_type: :insight, domain: 'd', content: 'c') }

    it 'tends all plants' do
      result = client.tend_greenhouse
      expect(result[:success]).to be true
      expect(result[:result][:total]).to eq(1)
    end
  end

  describe '#adjust_environment' do
    it 'adjusts conditions' do
      result = client.adjust_environment(temperature: 25.0, humidity: 0.70, light_level: 0.80)
      expect(result[:success]).to be true
    end
  end

  describe '#advance_season' do
    it 'cycles the season' do
      result = client.advance_season
      expect(result[:success]).to be true
      expect(result[:result][:season]).to eq(:summer)
    end
  end

  describe '#harvest_ideas' do
    it 'returns success with empty blooms initially' do
      result = client.harvest_ideas
      expect(result[:success]).to be true
      expect(result[:result][:harvested]).to eq(0)
    end
  end

  describe '#greenhouse_status' do
    it 'returns a complete report' do
      result = client.greenhouse_status
      expect(result[:success]).to be true
      expect(result[:result]).to have_key(:total_plants)
      expect(result[:result]).to have_key(:conditions)
    end
  end

  describe 'full lifecycle integration' do
    it 'plants, grows, blooms, and harvests an idea through all stages' do
      # Plant at mature stage so bloom! is available immediately
      custom_greenhouse = Legion::Extensions::CognitiveGreenhouse::Helpers::Greenhouse.new
      seedling = Legion::Extensions::CognitiveGreenhouse::Helpers::Seedling.new(
        plant_type: :theory, domain: 'integration', content: 'test idea',
        growth_stage: :mature, health: 0.9
      )
      seedling.bloom!
      custom_greenhouse.plant!(seedling)

      c = described_class.new(greenhouse: custom_greenhouse)
      harvest_result = c.harvest_ideas
      expect(harvest_result[:result][:harvested]).to eq(1)
    end
  end
end
