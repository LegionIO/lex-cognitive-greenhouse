# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveGreenhouse
      module Runners
        module CognitiveGreenhouse
          extend self

          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          def plant_idea(plant_type:, domain:, content:, growth_stage: :seed, health: 0.5, engine: nil, **)
            raise ArgumentError, "unknown plant_type: #{plant_type.inspect}" unless Helpers::Constants::PLANT_TYPES.include?(plant_type)

            e = engine || default_engine
            result = e.plant_in_greenhouse(
              plant_type:   plant_type,
              domain:       domain,
              content:      content,
              growth_stage: growth_stage,
              health:       health
            )

            Legion::Logging.debug "[greenhouse] planted #{plant_type} in #{domain}: #{result[:seedling][:id][0..7]}" if defined?(Legion::Logging)
            { success: result[:planted], result: result }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def tend_greenhouse(engine: nil, **)
            e = engine || default_engine
            result = e.grow_all!
            Legion::Logging.debug "[greenhouse] grow_all: grew=#{result[:grew]} total=#{result[:total]} season=#{result[:season]}" if defined?(Legion::Logging)
            { success: true, result: result }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def adjust_environment(temperature: nil, humidity: nil, light_level: nil, engine: nil, **)
            e = engine || default_engine
            result = e.adjust_environment(temperature: temperature, humidity: humidity, light_level: light_level)
            Legion::Logging.debug "[greenhouse] conditions adjusted: quality=#{result[:quality]}" if defined?(Legion::Logging)
            { success: true, result: result }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def advance_season(engine: nil, **)
            e = engine || default_engine
            result = e.cycle_season
            Legion::Logging.debug "[greenhouse] season cycled to #{result[:season]}" if defined?(Legion::Logging)
            { success: true, result: result }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def harvest_ideas(engine: nil, **)
            e = engine || default_engine
            result = e.harvest
            Legion::Logging.debug "[greenhouse] harvested #{result[:harvested]} blooms" if defined?(Legion::Logging)
            { success: true, result: result }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def greenhouse_status(engine: nil, **)
            e = engine || default_engine
            result = e.greenhouse_report
            { success: true, result: result }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          private

          def default_engine
            @default_engine ||= Helpers::GreenhouseEngine.new
          end
        end
      end
    end
  end
end
