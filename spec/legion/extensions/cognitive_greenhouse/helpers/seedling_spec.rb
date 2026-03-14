# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveGreenhouse::Helpers::Seedling do
  subject(:seedling) { described_class.new(plant_type: :hypothesis, domain: 'cognition', content: 'test idea') }

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(seedling.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets plant_type' do
      expect(seedling.plant_type).to eq(:hypothesis)
    end

    it 'sets domain' do
      expect(seedling.domain).to eq('cognition')
    end

    it 'sets content' do
      expect(seedling.content).to eq('test idea')
    end

    it 'defaults to seed stage' do
      expect(seedling.growth_stage).to eq(:seed)
    end

    it 'defaults health to 0.5' do
      expect(seedling.health).to eq(0.5)
    end

    it 'defaults root_depth to 0.0' do
      expect(seedling.root_depth).to eq(0.0)
    end

    it 'raises on invalid plant_type' do
      expect { described_class.new(plant_type: :invalid, domain: 'd', content: 'c') }
        .to raise_error(ArgumentError, /unknown plant_type/)
    end

    it 'raises on invalid growth_stage' do
      expect { described_class.new(plant_type: :insight, domain: 'd', content: 'c', growth_stage: :adult) }
        .to raise_error(ArgumentError, /unknown growth_stage/)
    end

    it 'clamps health above 1.0' do
      s = described_class.new(plant_type: :insight, domain: 'd', content: 'c', health: 2.5)
      expect(s.health).to eq(1.0)
    end

    it 'clamps health below 0.0' do
      s = described_class.new(plant_type: :insight, domain: 'd', content: 'c', health: -0.5)
      expect(s.health).to eq(0.0)
    end
  end

  describe '#grow!' do
    context 'with optimal conditions' do
      let(:conditions) { { temperature: 22.0, humidity: 0.65, light_level: 0.75 } }

      it 'returns grew: true' do
        result = seedling.grow!(conditions)
        expect(result[:grew]).to be true
      end

      it 'increases health' do
        before_health = seedling.health
        seedling.grow!(conditions)
        expect(seedling.health).to be > before_health
      end

      it 'increases root_depth' do
        seedling.grow!(conditions)
        expect(seedling.root_depth).to be > 0.0
      end

      it 'includes quality in result' do
        result = seedling.grow!(conditions)
        expect(result[:quality]).to be_between(0.0, 1.0)
      end
    end

    context 'with poor conditions' do
      let(:conditions) { { temperature: 0.0, humidity: 0.0, light_level: 0.0 } }

      it 'returns grew: false' do
        result = seedling.grow!(conditions)
        expect(result[:grew]).to be false
      end

      it 'returns reason :poor_environment' do
        result = seedling.grow!(conditions)
        expect(result[:reason]).to eq(:poor_environment)
      end
    end

    context 'with empty conditions' do
      it 'uses default quality of 0.5 and can grow' do
        result = seedling.grow!({})
        # quality 0.5 >= MIN_QUALITY_FOR_GROWTH (0.40)
        expect(result[:grew]).to be true
      end
    end

    it 'advances stage when health crosses threshold after enough grows' do
      high_health_seedling = described_class.new(plant_type: :insight, domain: 'd', content: 'c', health: 0.8)
      conditions = { temperature: 22.0, humidity: 0.65, light_level: 0.75 }
      result = high_health_seedling.grow!(conditions)
      expect(result[:stage_change]).to be true
      expect(high_health_seedling.growth_stage).to eq(:sprout)
    end

    it 'does not advance stage past mature (bloom is explicit)' do
      mature = described_class.new(plant_type: :insight, domain: 'd', content: 'c',
                                   growth_stage: :mature, health: 0.9)
      conditions = { temperature: 22.0, humidity: 0.65, light_level: 0.75 }
      mature.grow!(conditions)
      expect(mature.growth_stage).to eq(:mature)
    end
  end

  describe '#wilt!' do
    it 'reduces health' do
      before_health = seedling.health
      seedling.wilt!(0.5)
      expect(seedling.health).to be < before_health
    end

    it 'returns a wilt result hash' do
      result = seedling.wilt!(0.5)
      expect(result[:wilted]).to be true
      expect(result[:health]).to be_a(Float)
    end

    it 'clamps stress to [0, 1]' do
      result = seedling.wilt!(5.0)
      expect(result[:stress]).to eq(1.0)
    end

    it 'does not allow health below 0.0' do
      seedling.wilt!(1.0)
      seedling.wilt!(1.0)
      seedling.wilt!(1.0)
      expect(seedling.health).to be >= 0.0
    end
  end

  describe '#bloom!' do
    context 'when plant is mature' do
      subject(:mature_seedling) do
        described_class.new(plant_type: :theory, domain: 'd', content: 'c', growth_stage: :mature, health: 0.7)
      end

      it 'transitions to bloom stage' do
        mature_seedling.bloom!
        expect(mature_seedling.growth_stage).to eq(:bloom)
      end

      it 'returns bloomed: true' do
        result = mature_seedling.bloom!
        expect(result[:bloomed]).to be true
      end

      it 'boosts health slightly' do
        before_health = mature_seedling.health
        mature_seedling.bloom!
        expect(mature_seedling.health).to be >= before_health
      end
    end

    context 'when plant is not mature' do
      it 'returns bloomed: false' do
        result = seedling.bloom!
        expect(result[:bloomed]).to be false
        expect(result[:reason]).to eq(:not_mature)
      end
    end
  end

  describe '#healthy?' do
    it 'returns true when health >= 0.6' do
      s = described_class.new(plant_type: :insight, domain: 'd', content: 'c', health: 0.8)
      expect(s.healthy?).to be true
    end

    it 'returns false when health < 0.6' do
      s = described_class.new(plant_type: :insight, domain: 'd', content: 'c', health: 0.5)
      expect(s.healthy?).to be false
    end
  end

  describe '#wilting?' do
    it 'returns true when health < 0.3' do
      s = described_class.new(plant_type: :insight, domain: 'd', content: 'c', health: 0.2)
      expect(s.wilting?).to be true
    end

    it 'returns false when health >= 0.3' do
      expect(seedling.wilting?).to be false
    end
  end

  describe '#mature?' do
    it 'returns true when growth_stage is :mature' do
      s = described_class.new(plant_type: :insight, domain: 'd', content: 'c', growth_stage: :mature)
      expect(s.mature?).to be true
    end

    it 'returns false for other stages' do
      expect(seedling.mature?).to be false
    end
  end

  describe '#to_h' do
    it 'returns a hash with all key fields' do
      h = seedling.to_h
      expect(h.keys).to include(:id, :plant_type, :domain, :content, :growth_stage, :health, :root_depth, :planted_at, :last_tended)
    end

    it 'rounds health to 10 decimal places' do
      h = seedling.to_h
      expect(h[:health]).to be_a(Float)
    end
  end
end
