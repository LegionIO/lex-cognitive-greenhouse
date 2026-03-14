# frozen_string_literal: true

require 'securerandom'
require_relative 'cognitive_greenhouse/version'
require_relative 'cognitive_greenhouse/helpers/constants'
require_relative 'cognitive_greenhouse/helpers/seedling'
require_relative 'cognitive_greenhouse/helpers/greenhouse'
require_relative 'cognitive_greenhouse/helpers/greenhouse_engine'
require_relative 'cognitive_greenhouse/runners/cognitive_greenhouse'
require_relative 'cognitive_greenhouse/client'

module Legion
  module Extensions
    module CognitiveGreenhouse
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
