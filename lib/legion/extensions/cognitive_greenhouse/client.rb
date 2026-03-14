# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveGreenhouse
      class Client
        include Runners::CognitiveGreenhouse

        def initialize(greenhouse: nil, **)
          @greenhouse      = greenhouse || Helpers::Greenhouse.new
          @default_engine  = Helpers::GreenhouseEngine.new(greenhouse: @greenhouse)
        end

        private

        attr_reader :greenhouse
      end
    end
  end
end
