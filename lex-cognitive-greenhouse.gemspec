# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_greenhouse/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-cognitive-greenhouse'
  spec.version       = Legion::Extensions::CognitiveGreenhouse::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Cognitive Greenhouse'
  spec.description   = 'Protected environment for growing ideas from seeds to mature concepts — ' \
                       'temperature, humidity, and light as nurturing conditions, with seasonal cycles'
  spec.homepage      = 'https://github.com/LegionIO/lex-cognitive-greenhouse'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']        = spec.homepage
  spec.metadata['source_code_uri']     = 'https://github.com/LegionIO/lex-cognitive-greenhouse'
  spec.metadata['documentation_uri']   = 'https://github.com/LegionIO/lex-cognitive-greenhouse'
  spec.metadata['changelog_uri']       = 'https://github.com/LegionIO/lex-cognitive-greenhouse'
  spec.metadata['bug_tracker_uri']     = 'https://github.com/LegionIO/lex-cognitive-greenhouse/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']
end
