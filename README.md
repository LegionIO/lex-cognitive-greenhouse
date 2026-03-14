# lex-cognitive-greenhouse

Controlled cognitive growth environment for brain-modeled agentic AI in the LegionIO ecosystem.

## What It Does

Models a seasonal, environmentally controlled space for maturing cognitive ideas. Plants (concepts, theories, insights, beliefs) grow at rates determined by the current season (spring through winter) only when environmental quality (temperature, humidity, light) meets minimum thresholds. Environment can be manually adjusted or automatically shifted by advancing seasons. Plants that reach the bloom stage can be harvested, removing them from the active set. The greenhouse provides finer control than an open garden — limited capacity, explicit conditions, and seasonal cycles.

## Usage

```ruby
require 'legion/extensions/cognitive_greenhouse'

client = Legion::Extensions::CognitiveGreenhouse::Client.new

# Plant an idea in the greenhouse
result = client.plant_idea(plant_type: :insight, domain: :systems, content: 'eventual consistency trade-offs')
plant_id = result[:plant_id]

# Adjust environment for optimal growth
client.adjust_environment(temperature: 0.65, humidity: 0.70, light: 0.75)
# => { success: true, environment: { quality: 0.69, season: :spring, ... } }

# Tend all plants (applies seasonal growth rate)
client.tend_greenhouse
# => { success: true, grown: 1 }

# Advance the season
client.advance_season
# => { success: true, season: :summer, environment: { ... } }

# Harvest bloomed plants
client.harvest_ideas
# => { success: true, harvested: [{ plant_id: "...", type: :insight, ... }] }

# Full status
client.greenhouse_status
# => { success: true, report: { plant_count: 0, season: :summer, ... } }
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
