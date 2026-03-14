# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveGreenhouse
      module Helpers
        class GreenhouseEngine
          include Constants

          attr_reader :greenhouse

          def initialize(greenhouse: nil)
            @greenhouse = greenhouse || Greenhouse.new
          end

          def create_plant(plant_type:, domain:, content:, growth_stage: :seed, health: 0.5)
            raise ArgumentError, "unknown plant_type: #{plant_type.inspect}" unless Constants::PLANT_TYPES.include?(plant_type)

            Seedling.new(
              plant_type:   plant_type,
              domain:       domain,
              content:      content,
              growth_stage: growth_stage,
              health:       health
            )
          end

          def plant_in_greenhouse(plant_type:, domain:, content:, growth_stage: :seed, health: 0.5, **)
            seedling = create_plant(
              plant_type:   plant_type,
              domain:       domain,
              content:      content,
              growth_stage: growth_stage,
              health:       health
            )
            result = @greenhouse.plant!(seedling)
            result.merge(seedling: seedling.to_h)
          end

          def grow_all!
            conditions = current_conditions
            rate       = Constants::GROWTH_RATE.fetch(@greenhouse.season, 1.0)
            grew_count = 0
            results    = []

            @greenhouse.plants.each do |plant|
              result = plant.grow!(conditions.merge(rate: rate))
              results << result.merge(id: plant.id)
              grew_count += 1 if result[:grew]
            end

            { grew: grew_count, total: @greenhouse.plants.size, results: results, season: @greenhouse.season }
          end

          def adjust_environment(temperature: nil, humidity: nil, light_level: nil, **)
            @greenhouse.adjust_conditions(
              temperature: temperature,
              humidity:    humidity,
              light_level: light_level
            )
          end

          def cycle_season
            result = @greenhouse.cycle_season!

            # Apply seasonal light/temp shifts automatically
            case result[:season]
            when :spring
              @greenhouse.adjust_conditions(temperature: 20.0, humidity: 0.70, light_level: 0.75)
            when :summer
              @greenhouse.adjust_conditions(temperature: 26.0, humidity: 0.60, light_level: 0.90)
            when :autumn
              @greenhouse.adjust_conditions(temperature: 16.0, humidity: 0.65, light_level: 0.65)
            when :winter
              @greenhouse.adjust_conditions(temperature: 10.0, humidity: 0.55, light_level: 0.45)
            end

            result.merge(conditions: @greenhouse.condition_snapshot)
          end

          def harvest
            blooms = @greenhouse.harvest_blooms
            { harvested: blooms.size, blooms: blooms }
          end

          def greenhouse_report
            plants_by_stage = Constants::GROWTH_STAGES.to_h do |stage|
              [stage, @greenhouse.plants.count { |p| p.growth_stage == stage }]
            end

            healthy_count = @greenhouse.plants.count(&:healthy?)
            wilting_count = @greenhouse.plants.count(&:wilting?)

            {
              total_plants:    @greenhouse.plants.size,
              plants_by_stage: plants_by_stage,
              healthy:         healthy_count,
              wilting:         wilting_count,
              conditions:      @greenhouse.condition_snapshot,
              cycles:          @greenhouse.cycles_completed
            }
          end

          private

          def current_conditions
            {
              temperature: @greenhouse.temperature,
              humidity:    @greenhouse.humidity,
              light_level: @greenhouse.light_level
            }
          end
        end
      end
    end
  end
end
