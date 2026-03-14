# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveGreenhouse
      module Helpers
        class Greenhouse
          include Constants

          SEASON_CYCLE = Constants::SEASONS.freeze

          attr_reader :temperature, :humidity, :light_level, :season, :plants, :created_at, :cycles_completed

          def initialize(temperature: 22.0, humidity: 0.65, light_level: 0.75, season: :spring)
            raise ArgumentError, "unknown season: #{season.inspect}" unless Constants::SEASONS.include?(season)

            @temperature      = temperature.clamp(0.0, 50.0)
            @humidity         = humidity.clamp(0.0, 1.0)
            @light_level      = light_level.clamp(0.0, 1.0)
            @season           = season
            @plants           = []
            @created_at       = Time.now.utc
            @cycles_completed = 0
          end

          def plant!(seedling)
            raise ArgumentError, 'seedling must be a Seedling instance' unless seedling.is_a?(Seedling)

            return { planted: false, reason: :greenhouse_full, capacity: Constants::MAX_PLANTS } if @plants.size >= Constants::MAX_PLANTS

            @plants << seedling
            { planted: true, id: seedling.id, total_plants: @plants.size }
          end

          def adjust_conditions(temperature: nil, humidity: nil, light_level: nil)
            @temperature  = temperature.clamp(0.0, 50.0)  if temperature
            @humidity     = humidity.clamp(0.0, 1.0)      if humidity
            @light_level  = light_level.clamp(0.0, 1.0) if light_level

            {
              temperature: @temperature,
              humidity:    @humidity,
              light_level: @light_level,
              quality:     environment_quality.round(10)
            }
          end

          def cycle_season!
            current_index = SEASON_CYCLE.index(@season)
            @season = SEASON_CYCLE[(current_index + 1) % SEASON_CYCLE.size]
            @cycles_completed += 1
            { season: @season, cycle: @cycles_completed }
          end

          def environment_quality
            temp_score     = score_condition(@temperature, Constants::IDEAL_TEMPERATURE[0], Constants::IDEAL_TEMPERATURE[1], 0.0, 50.0)
            humidity_score = score_condition(@humidity, Constants::IDEAL_HUMIDITY[0], Constants::IDEAL_HUMIDITY[1], 0.0, 1.0)
            light_score    = score_condition(@light_level, Constants::IDEAL_LIGHT[0], Constants::IDEAL_LIGHT[1], 0.0, 1.0)

            (temp_score * Constants::CONDITION_WEIGHTS[:temperature]) +
              (humidity_score * Constants::CONDITION_WEIGHTS[:humidity]) +
              (light_score    * Constants::CONDITION_WEIGHTS[:light])
          end

          def harvest_blooms
            bloomed, remaining = @plants.partition { |p| p.growth_stage == Constants::HARVESTABLE_STAGE }
            @plants = remaining
            bloomed.map(&:to_h)
          end

          def condition_snapshot
            {
              temperature:    @temperature,
              humidity:       @humidity,
              light_level:    @light_level,
              season:         @season,
              quality:        environment_quality.round(10),
              temp_label:     label_for(:temperature, @temperature),
              humidity_label: label_for(:humidity, @humidity),
              light_label:    label_for(:light, @light_level)
            }
          end

          def active_plants
            @plants.reject { |p| p.growth_stage == :bloom }
          end

          private

          def score_condition(value, ideal_min, ideal_max, abs_min, abs_max)
            return 1.0 if value.between?(ideal_min, ideal_max)

            if value < ideal_min
              distance = ideal_min - value
              1.0 - (distance / (ideal_min - abs_min + 0.001)).clamp(0.0, 1.0)
            else
              distance = value - ideal_max
              1.0 - (distance / (abs_max - ideal_max + 0.001)).clamp(0.0, 1.0)
            end
          end

          def label_for(condition, value)
            Constants::CONDITION_LABELS[condition].each do |range, label|
              return label if range.cover?(value)
            end
            :unknown
          end
        end
      end
    end
  end
end
