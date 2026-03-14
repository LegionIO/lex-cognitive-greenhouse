# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveGreenhouse::Helpers::Greenhouse do
  subject(:greenhouse) { described_class.new }

  let(:seedling) do
    Legion::Extensions::CognitiveGreenhouse::Helpers::Seedling.new(
      plant_type: :hypothesis, domain: 'test', content: 'test idea'
    )
  end

  describe '#initialize' do
    it 'sets default temperature' do
      expect(greenhouse.temperature).to eq(22.0)
    end

    it 'sets default humidity' do
      expect(greenhouse.humidity).to eq(0.65)
    end

    it 'sets default light_level' do
      expect(greenhouse.light_level).to eq(0.75)
    end

    it 'defaults to spring season' do
      expect(greenhouse.season).to eq(:spring)
    end

    it 'starts with no plants' do
      expect(greenhouse.plants).to be_empty
    end

    it 'raises on invalid season' do
      expect { described_class.new(season: :monsoon) }.to raise_error(ArgumentError, /unknown season/)
    end

    it 'accepts a custom season' do
      g = described_class.new(season: :winter)
      expect(g.season).to eq(:winter)
    end

    it 'clamps temperature to [0, 50]' do
      g = described_class.new(temperature: 100.0)
      expect(g.temperature).to eq(50.0)
    end

    it 'clamps humidity to [0, 1]' do
      g = described_class.new(humidity: 2.0)
      expect(g.humidity).to eq(1.0)
    end
  end

  describe '#plant!' do
    it 'accepts a seedling' do
      result = greenhouse.plant!(seedling)
      expect(result[:planted]).to be true
    end

    it 'adds plant to the plants array' do
      greenhouse.plant!(seedling)
      expect(greenhouse.plants.size).to eq(1)
    end

    it 'returns total_plants count' do
      result = greenhouse.plant!(seedling)
      expect(result[:total_plants]).to eq(1)
    end

    it 'raises on non-seedling argument' do
      expect { greenhouse.plant!('not a seedling') }.to raise_error(ArgumentError, /Seedling instance/)
    end

    it 'refuses planting when at capacity' do
      stub_const('Legion::Extensions::CognitiveGreenhouse::Helpers::Constants::MAX_PLANTS', 1)
      greenhouse.plant!(seedling)
      second = Legion::Extensions::CognitiveGreenhouse::Helpers::Seedling.new(
        plant_type: :insight, domain: 'd', content: 'c'
      )
      result = greenhouse.plant!(second)
      expect(result[:planted]).to be false
      expect(result[:reason]).to eq(:greenhouse_full)
    end
  end

  describe '#adjust_conditions' do
    it 'updates temperature' do
      greenhouse.adjust_conditions(temperature: 28.0)
      expect(greenhouse.temperature).to eq(28.0)
    end

    it 'updates humidity' do
      greenhouse.adjust_conditions(humidity: 0.80)
      expect(greenhouse.humidity).to eq(0.80)
    end

    it 'updates light_level' do
      greenhouse.adjust_conditions(light_level: 0.90)
      expect(greenhouse.light_level).to eq(0.90)
    end

    it 'returns quality in result hash' do
      result = greenhouse.adjust_conditions(temperature: 22.0, humidity: 0.65, light_level: 0.75)
      expect(result[:quality]).to be_between(0.0, 1.0)
    end

    it 'ignores nil arguments' do
      original_temp = greenhouse.temperature
      greenhouse.adjust_conditions(humidity: 0.70)
      expect(greenhouse.temperature).to eq(original_temp)
    end
  end

  describe '#cycle_season!' do
    it 'advances from spring to summer' do
      result = greenhouse.cycle_season!
      expect(result[:season]).to eq(:summer)
    end

    it 'wraps from winter back to spring' do
      g = described_class.new(season: :winter)
      result = g.cycle_season!
      expect(result[:season]).to eq(:spring)
    end

    it 'increments cycles_completed' do
      greenhouse.cycle_season!
      expect(greenhouse.cycles_completed).to eq(1)
    end
  end

  describe '#environment_quality' do
    it 'returns a float between 0 and 1' do
      q = greenhouse.environment_quality
      expect(q).to be_between(0.0, 1.0)
    end

    it 'returns near 1.0 for optimal conditions' do
      g = described_class.new(temperature: 22.0, humidity: 0.65, light_level: 0.75)
      expect(g.environment_quality).to be > 0.9
    end

    it 'returns lower quality for extreme conditions' do
      g = described_class.new(temperature: 0.0, humidity: 0.0, light_level: 0.0)
      expect(g.environment_quality).to be < 0.2
    end
  end

  describe '#harvest_blooms' do
    before do
      bloom_seedling = Legion::Extensions::CognitiveGreenhouse::Helpers::Seedling.new(
        plant_type: :theory, domain: 'd', content: 'c', growth_stage: :mature, health: 0.8
      )
      bloom_seedling.bloom!
      greenhouse.plant!(bloom_seedling)
      greenhouse.plant!(seedling)
    end

    it 'returns bloomed plants as hashes' do
      blooms = greenhouse.harvest_blooms
      expect(blooms.size).to eq(1)
      expect(blooms.first[:growth_stage]).to eq(:bloom)
    end

    it 'removes bloomed plants from plants array' do
      greenhouse.harvest_blooms
      expect(greenhouse.plants.none? { |p| p.growth_stage == :bloom }).to be true
    end
  end

  describe '#condition_snapshot' do
    it 'includes temperature, humidity, light_level, season, quality, and labels' do
      snapshot = greenhouse.condition_snapshot
      expect(snapshot.keys).to include(:temperature, :humidity, :light_level, :season, :quality,
                                       :temp_label, :humidity_label, :light_label)
    end

    it 'labels optimal temperature as :optimal' do
      expect(greenhouse.condition_snapshot[:temp_label]).to eq(:optimal)
    end
  end

  describe '#active_plants' do
    it 'excludes bloomed plants' do
      bloom_seedling = Legion::Extensions::CognitiveGreenhouse::Helpers::Seedling.new(
        plant_type: :theory, domain: 'd', content: 'c', growth_stage: :mature, health: 0.9
      )
      bloom_seedling.bloom!
      greenhouse.plant!(bloom_seedling)
      greenhouse.plant!(seedling)
      expect(greenhouse.active_plants.size).to eq(1)
    end
  end
end
