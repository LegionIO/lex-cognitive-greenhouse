# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveGreenhouse::Runners::CognitiveGreenhouse do
  let(:greenhouse) { Legion::Extensions::CognitiveGreenhouse::Helpers::Greenhouse.new }
  let(:engine) { Legion::Extensions::CognitiveGreenhouse::Helpers::GreenhouseEngine.new(greenhouse: greenhouse) }

  # Use a throwaway object that extends the runner module so private state is isolated per example
  let(:runner) do
    obj = Object.new
    obj.extend(described_class)
    obj
  end

  describe '#plant_idea' do
    it 'returns success: true for a valid idea' do
      result = runner.plant_idea(plant_type: :hypothesis, domain: 'cognition', content: 'test', engine: engine)
      expect(result[:success]).to be true
    end

    it 'returns the planted seedling in result' do
      result = runner.plant_idea(plant_type: :insight, domain: 'ai', content: 'test', engine: engine)
      expect(result[:result][:seedling][:plant_type]).to eq(:insight)
    end

    it 'returns success: false for invalid plant_type' do
      result = runner.plant_idea(plant_type: :bad, domain: 'd', content: 'c', engine: engine)
      expect(result[:success]).to be false
      expect(result[:error]).to match(/unknown plant_type/)
    end

    it 'uses the injected engine' do
      runner.plant_idea(plant_type: :question, domain: 'd', content: 'c', engine: engine)
      expect(engine.greenhouse.plants.size).to eq(1)
    end
  end

  describe '#tend_greenhouse' do
    before do
      engine.plant_in_greenhouse(plant_type: :hypothesis, domain: 'd', content: 'c')
    end

    it 'returns success: true' do
      result = runner.tend_greenhouse(engine: engine)
      expect(result[:success]).to be true
    end

    it 'returns grow_all results' do
      result = runner.tend_greenhouse(engine: engine)
      expect(result[:result]).to have_key(:grew)
      expect(result[:result]).to have_key(:total)
    end
  end

  describe '#adjust_environment' do
    it 'returns success: true' do
      result = runner.adjust_environment(temperature: 24.0, engine: engine)
      expect(result[:success]).to be true
    end

    it 'updates greenhouse temperature via engine' do
      runner.adjust_environment(temperature: 24.0, engine: engine)
      expect(greenhouse.temperature).to eq(24.0)
    end

    it 'returns updated quality in result' do
      result = runner.adjust_environment(temperature: 22.0, humidity: 0.65, engine: engine)
      expect(result[:result][:quality]).to be_a(Float)
    end
  end

  describe '#advance_season' do
    it 'returns success: true' do
      result = runner.advance_season(engine: engine)
      expect(result[:success]).to be true
    end

    it 'advances the season' do
      runner.advance_season(engine: engine)
      expect(greenhouse.season).to eq(:summer)
    end

    it 'returns season in result' do
      result = runner.advance_season(engine: engine)
      expect(result[:result][:season]).to eq(:summer)
    end
  end

  describe '#harvest_ideas' do
    it 'returns success: true' do
      result = runner.harvest_ideas(engine: engine)
      expect(result[:success]).to be true
    end

    it 'returns harvested count' do
      result = runner.harvest_ideas(engine: engine)
      expect(result[:result][:harvested]).to eq(0)
    end

    it 'collects bloomed plants' do
      mature = Legion::Extensions::CognitiveGreenhouse::Helpers::Seedling.new(
        plant_type: :theory, domain: 'd', content: 'c', growth_stage: :mature, health: 0.9
      )
      mature.bloom!
      greenhouse.plant!(mature)
      result = runner.harvest_ideas(engine: engine)
      expect(result[:result][:harvested]).to eq(1)
    end
  end

  describe '#greenhouse_status' do
    it 'returns success: true' do
      result = runner.greenhouse_status(engine: engine)
      expect(result[:success]).to be true
    end

    it 'returns report with total_plants' do
      result = runner.greenhouse_status(engine: engine)
      expect(result[:result]).to have_key(:total_plants)
    end

    it 'returns report with conditions' do
      result = runner.greenhouse_status(engine: engine)
      expect(result[:result]).to have_key(:conditions)
    end
  end

  describe 'default_engine memoization' do
    it 'creates a default engine when none provided' do
      result = runner.greenhouse_status
      expect(result[:success]).to be true
    end

    it 'reuses the same engine across calls' do
      runner.plant_idea(plant_type: :hypothesis, domain: 'd', content: 'c')
      status = runner.greenhouse_status
      expect(status[:result][:total_plants]).to eq(1)
    end
  end
end
