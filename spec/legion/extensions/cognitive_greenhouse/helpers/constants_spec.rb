# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveGreenhouse::Helpers::Constants do
  describe 'SEASONS' do
    it 'contains the four seasons' do
      expect(described_class::SEASONS).to eq(%i[spring summer autumn winter])
    end

    it 'is frozen' do
      expect(described_class::SEASONS).to be_frozen
    end
  end

  describe 'GROWTH_STAGES' do
    it 'contains exactly five stages' do
      expect(described_class::GROWTH_STAGES).to eq(%i[seed sprout sapling mature bloom])
    end
  end

  describe 'PLANT_TYPES' do
    it 'includes hypothesis and insight' do
      expect(described_class::PLANT_TYPES).to include(:hypothesis, :insight)
    end

    it 'contains 8 types' do
      expect(described_class::PLANT_TYPES.size).to eq(8)
    end
  end

  describe 'MAX_PLANTS' do
    it 'is 50' do
      expect(described_class::MAX_PLANTS).to eq(50)
    end
  end

  describe 'GROWTH_RATE' do
    it 'spring has the highest rate' do
      expect(described_class::GROWTH_RATE[:spring]).to be > described_class::GROWTH_RATE[:winter]
    end

    it 'winter has the lowest rate' do
      min = described_class::GROWTH_RATE.values.min
      expect(described_class::GROWTH_RATE[:winter]).to eq(min)
    end
  end

  describe 'CONDITION_LABELS' do
    it 'has entries for temperature, humidity, and light' do
      expect(described_class::CONDITION_LABELS.keys).to contain_exactly(:temperature, :humidity, :light)
    end

    it 'optimal temperature range is labeled :optimal' do
      label = described_class::CONDITION_LABELS[:temperature].find { |r, _| r.cover?(22.0) }&.last
      expect(label).to eq(:optimal)
    end

    it 'optimal humidity range is labeled :optimal' do
      label = described_class::CONDITION_LABELS[:humidity].find { |r, _| r.cover?(0.65) }&.last
      expect(label).to eq(:optimal)
    end

    it 'optimal light range is labeled :optimal' do
      label = described_class::CONDITION_LABELS[:light].find { |r, _| r.cover?(0.75) }&.last
      expect(label).to eq(:optimal)
    end
  end

  describe 'CONDITION_WEIGHTS' do
    it 'weights sum to 1.0' do
      total = described_class::CONDITION_WEIGHTS.values.sum
      expect(total).to be_within(0.001).of(1.0)
    end
  end
end
