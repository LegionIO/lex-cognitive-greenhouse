# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveGreenhouse
      module Helpers
        class Seedling
          include Constants

          STAGE_INDEX = Constants::GROWTH_STAGES.each_with_index.to_h.freeze

          attr_reader :id, :plant_type, :domain, :content, :growth_stage, :health,
                      :root_depth, :planted_at, :last_tended

          def initialize(plant_type:, domain:, content:, growth_stage: :seed, health: 0.5, root_depth: 0.0)
            raise ArgumentError, "unknown plant_type: #{plant_type.inspect}" unless Constants::PLANT_TYPES.include?(plant_type)
            raise ArgumentError, "unknown growth_stage: #{growth_stage.inspect}" unless Constants::GROWTH_STAGES.include?(growth_stage)

            @id           = SecureRandom.uuid
            @plant_type   = plant_type
            @domain       = domain
            @content      = content
            @growth_stage = growth_stage
            @health       = health.clamp(0.0, 1.0)
            @root_depth   = root_depth.clamp(0.0, 1.0)
            @planted_at   = Time.now.utc
            @last_tended  = Time.now.utc
          end

          def grow!(conditions = {})
            quality = environment_quality(conditions)
            return { grew: false, reason: :poor_environment, quality: quality.round(10) } if quality < Constants::MIN_QUALITY_FOR_GROWTH

            boost = (Constants::GROW_HEALTH_BOOST * quality).round(10)
            @health = (@health + boost).clamp(0.0, 1.0)
            @root_depth = (@root_depth + (boost * 0.5)).clamp(0.0, 1.0)
            @last_tended = Time.now.utc

            advanced = maybe_advance_stage!
            {
              grew:         true,
              health:       @health.round(10),
              root_depth:   @root_depth.round(10),
              stage:        @growth_stage,
              stage_change: advanced,
              quality:      quality.round(10)
            }
          end

          def wilt!(stress = 0.5)
            drain = (Constants::WILT_HEALTH_DRAIN * stress.clamp(0.0, 1.0)).round(10)
            @health = (@health - drain).clamp(0.0, 1.0)
            @last_tended = Time.now.utc
            { wilted: true, health: @health.round(10), stress: stress.clamp(0.0, 1.0).round(10) }
          end

          def bloom!
            return { bloomed: false, reason: :not_mature } unless mature?

            @growth_stage = :bloom
            @health       = (@health + 0.10).clamp(0.0, 1.0)
            @last_tended  = Time.now.utc
            { bloomed: true, health: @health.round(10), id: @id }
          end

          def healthy?
            @health >= 0.6
          end

          def wilting?
            @health < 0.3
          end

          def mature?
            @growth_stage == :mature
          end

          def to_h
            {
              id:           @id,
              plant_type:   @plant_type,
              domain:       @domain,
              content:      @content,
              growth_stage: @growth_stage,
              health:       @health.round(10),
              root_depth:   @root_depth.round(10),
              planted_at:   @planted_at,
              last_tended:  @last_tended
            }
          end

          private

          def environment_quality(conditions)
            return 0.5 if conditions.empty?

            temp_score = score_temperature(conditions.fetch(:temperature, 22.0))
            humidity_score = score_humidity(conditions.fetch(:humidity, 0.65))
            light_score = score_light(conditions.fetch(:light_level, 0.75))

            (temp_score * Constants::CONDITION_WEIGHTS[:temperature]) +
              (humidity_score * Constants::CONDITION_WEIGHTS[:humidity]) +
              (light_score    * Constants::CONDITION_WEIGHTS[:light])
          end

          def score_temperature(value)
            score_in_range(value, Constants::IDEAL_TEMPERATURE[0], Constants::IDEAL_TEMPERATURE[1], 0.0, 50.0)
          end

          def score_humidity(value)
            score_in_range(value, Constants::IDEAL_HUMIDITY[0], Constants::IDEAL_HUMIDITY[1], 0.0, 1.0)
          end

          def score_light(value)
            score_in_range(value, Constants::IDEAL_LIGHT[0], Constants::IDEAL_LIGHT[1], 0.0, 1.0)
          end

          def score_in_range(value, ideal_min, ideal_max, abs_min, abs_max)
            return 1.0 if value.between?(ideal_min, ideal_max)

            range_span = (abs_max - abs_min).to_f
            return 0.0 if range_span.zero?

            if value < ideal_min
              distance = ideal_min - value
              1.0 - (distance / (ideal_min - abs_min + 0.001)).clamp(0.0, 1.0)
            else
              distance = value - ideal_max
              1.0 - (distance / (abs_max - ideal_max + 0.001)).clamp(0.0, 1.0)
            end
          end

          def maybe_advance_stage!
            return false if @growth_stage == :bloom
            return false if @health < Constants::STAGE_ADVANCE_THRESHOLD

            current_index = STAGE_INDEX[@growth_stage]
            next_stage    = Constants::GROWTH_STAGES[current_index + 1]
            return false unless next_stage
            return false if next_stage == :bloom # bloom! is explicit

            @growth_stage = next_stage
            true
          end
        end
      end
    end
  end
end
