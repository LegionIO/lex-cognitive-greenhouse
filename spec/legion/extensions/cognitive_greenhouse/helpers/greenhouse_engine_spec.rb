# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveGreenhouse::Helpers::GreenhouseEngine do
  subject(:engine) { described_class.new }

  describe '#initialize' do
    it 'creates a default greenhouse' do
      expect(engine.greenhouse).to be_a(Legion::Extensions::CognitiveGreenhouse::Helpers::Greenhouse)
    end

    it 'accepts an injected greenhouse' do
      custom = Legion::Extensions::CognitiveGreenhouse::Helpers::Greenhouse.new(season: :autumn)
      e = described_class.new(greenhouse: custom)
      expect(e.greenhouse.season).to eq(:autumn)
    end
  end

  describe '#create_plant' do
    it 'returns a Seedling' do
      plant = engine.create_plant(plant_type: :insight, domain: 'reasoning', content: 'test')
      expect(plant).to be_a(Legion::Extensions::CognitiveGreenhouse::Helpers::Seedling)
    end

    it 'raises on invalid plant_type' do
      expect { engine.create_plant(plant_type: :bad, domain: 'd', content: 'c') }
        .to raise_error(ArgumentError, /unknown plant_type/)
    end
  end

  describe '#plant_in_greenhouse' do
    it 'returns planted: true on success' do
      result = engine.plant_in_greenhouse(plant_type: :hypothesis, domain: 'cognition', content: 'idea')
      expect(result[:planted]).to be true
    end

    it 'includes seedling data in result' do
      result = engine.plant_in_greenhouse(plant_type: :pattern, domain: 'language', content: 'test')
      expect(result[:seedling][:plant_type]).to eq(:pattern)
    end

    it 'adds plant to greenhouse' do
      engine.plant_in_greenhouse(plant_type: :question, domain: 'q', content: 'why?')
      expect(engine.greenhouse.plants.size).to eq(1)
    end
  end

  describe '#grow_all!' do
    before do
      3.times do |i|
        engine.plant_in_greenhouse(plant_type: :insight, domain: "d#{i}", content: "c#{i}")
      end
    end

    it 'returns grew count' do
      result = engine.grow_all!
      expect(result[:grew]).to be_a(Integer)
    end

    it 'returns total plants' do
      result = engine.grow_all!
      expect(result[:total]).to eq(3)
    end

    it 'returns season in result' do
      result = engine.grow_all!
      expect(result[:season]).to eq(:spring)
    end

    it 'returns results array with one entry per plant' do
      result = engine.grow_all!
      expect(result[:results].size).to eq(3)
    end
  end

  describe '#adjust_environment' do
    it 'updates greenhouse conditions' do
      engine.adjust_environment(temperature: 28.0, humidity: 0.70)
      expect(engine.greenhouse.temperature).to eq(28.0)
      expect(engine.greenhouse.humidity).to eq(0.70)
    end

    it 'returns condition snapshot with quality' do
      result = engine.adjust_environment(temperature: 22.0)
      expect(result[:quality]).to be_a(Float)
    end
  end

  describe '#cycle_season' do
    it 'advances the greenhouse season' do
      engine.cycle_season
      expect(engine.greenhouse.season).to eq(:summer)
    end

    it 'returns season and conditions' do
      result = engine.cycle_season
      expect(result[:season]).to eq(:summer)
      expect(result[:conditions]).to be_a(Hash)
    end

    it 'adjusts conditions automatically on season change' do
      engine.cycle_season # spring -> summer
      expect(engine.greenhouse.light_level).to eq(0.90)
    end

    it 'applies winter conditions in winter' do
      3.times { engine.cycle_season } # spring -> summer -> autumn -> winter
      expect(engine.greenhouse.season).to eq(:winter)
      expect(engine.greenhouse.light_level).to eq(0.45)
    end
  end

  describe '#harvest' do
    it 'returns harvested count' do
      result = engine.harvest
      expect(result[:harvested]).to eq(0)
    end

    it 'harvests bloomed plants' do
      mature = Legion::Extensions::CognitiveGreenhouse::Helpers::Seedling.new(
        plant_type: :theory, domain: 'd', content: 'c', growth_stage: :mature, health: 0.9
      )
      mature.bloom!
      engine.greenhouse.plant!(mature)

      result = engine.harvest
      expect(result[:harvested]).to eq(1)
      expect(result[:blooms].first[:growth_stage]).to eq(:bloom)
    end
  end

  describe '#greenhouse_report' do
    before do
      engine.plant_in_greenhouse(plant_type: :insight, domain: 'test', content: 'idea 1')
      engine.plant_in_greenhouse(plant_type: :pattern, domain: 'test', content: 'idea 2', health: 0.8)
    end

    it 'returns total_plants' do
      expect(engine.greenhouse_report[:total_plants]).to eq(2)
    end

    it 'returns plants_by_stage hash' do
      report = engine.greenhouse_report
      expect(report[:plants_by_stage]).to be_a(Hash)
      expect(report[:plants_by_stage].keys).to eq(Legion::Extensions::CognitiveGreenhouse::Helpers::Constants::GROWTH_STAGES)
    end

    it 'returns healthy count' do
      expect(engine.greenhouse_report[:healthy]).to be_a(Integer)
    end

    it 'returns wilting count' do
      expect(engine.greenhouse_report[:wilting]).to be_a(Integer)
    end

    it 'returns conditions snapshot' do
      expect(engine.greenhouse_report[:conditions]).to be_a(Hash)
    end

    it 'returns cycles count' do
      expect(engine.greenhouse_report[:cycles]).to eq(0)
    end
  end
end
