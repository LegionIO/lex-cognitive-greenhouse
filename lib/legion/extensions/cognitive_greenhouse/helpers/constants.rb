# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveGreenhouse
      module Helpers
        module Constants
          SEASONS = %i[spring summer autumn winter].freeze

          GROWTH_STAGES = %i[seed sprout sapling mature bloom].freeze

          PLANT_TYPES = %i[
            hypothesis
            insight
            question
            pattern
            analogy
            metaphor
            theory
            observation
          ].freeze

          MAX_PLANTS = 50

          # Growth rate multiplier per season (spring blooms, winter slows)
          GROWTH_RATE = {
            spring: 1.4,
            summer: 1.2,
            autumn: 0.9,
            winter: 0.5
          }.freeze

          # Ideal ranges per condition [min_ideal, max_ideal]
          IDEAL_TEMPERATURE = [18.0, 26.0].freeze
          IDEAL_HUMIDITY    = [0.55, 0.80].freeze
          IDEAL_LIGHT       = [0.60, 0.95].freeze

          CONDITION_LABELS = {
            temperature: {
              (0.0...10.0)  => :frozen,
              (10.0...18.0) => :cool,
              (18.0...26.0) => :optimal,
              (26.0...34.0) => :warm,
              (34.0..50.0)  => :hot
            },
            humidity:    {
              (0.0...0.30)  => :arid,
              (0.30...0.55) => :dry,
              (0.55...0.80) => :optimal,
              (0.80...0.90) => :humid,
              (0.90..1.0)   => :saturated
            },
            light:       {
              (0.0...0.20)  => :dark,
              (0.20...0.40) => :dim,
              (0.40...0.60) => :moderate,
              (0.60...0.95) => :optimal,
              (0.95..1.0)   => :intense
            }
          }.freeze

          # How much each condition contributes to environment quality
          CONDITION_WEIGHTS = {
            temperature: 0.35,
            humidity:    0.30,
            light:       0.35
          }.freeze

          # Health change per grow! or wilt! call
          GROW_HEALTH_BOOST  = 0.08
          WILT_HEALTH_DRAIN  = 0.12

          # Stage advance threshold (health must be above this)
          STAGE_ADVANCE_THRESHOLD = 0.65

          # Minimum environment quality to allow growth
          MIN_QUALITY_FOR_GROWTH  = 0.40

          # Harvest only fully bloomed plants
          HARVESTABLE_STAGE = :bloom
        end
      end
    end
  end
end
