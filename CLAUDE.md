# lex-cognitive-greenhouse

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-cognitive-greenhouse`

## Purpose

Models a controlled cognitive growth environment with seasonal cycles and environmental conditions. Unlike the open-air garden, the greenhouse maintains explicit environmental variables (temperature, humidity, light) and advances through four seasons that alter growth rates. Plants grow only when environment quality meets minimum thresholds. Season transitions automatically adjust environmental conditions. Plants that reach the harvestable stage (`:bloom`) can be harvested, removing them from the active plant set. The engine tracks quality scores and growth stage distribution across plants.

## Gem Info

| Field | Value |
|---|---|
| Gem name | `lex-cognitive-greenhouse` |
| Version | `0.1.0` |
| Namespace | `Legion::Extensions::CognitiveGreenhouse` |
| Ruby | `>= 3.4` |
| License | MIT |
| GitHub | https://github.com/LegionIO/lex-cognitive-greenhouse |

## File Structure

```
lib/legion/extensions/cognitive_greenhouse/
  cognitive_greenhouse.rb           # Top-level require
  version.rb                        # VERSION = '0.1.0'
  client.rb                         # Client class
  helpers/
    constants.rb                    # Seasons, stages, plant types, rates, ideal conditions, labels
    plant.rb                        # Plant value object (with quality tracking)
    greenhouse_engine.rb            # Engine: plants, environment, seasons, growth, harvest
  runners/
    cognitive_greenhouse.rb         # Runner module (extend self)
```

## Key Constants

| Constant | Value | Meaning |
|---|---|---|
| `SEASONS` | array | `[:spring, :summer, :autumn, :winter]` |
| `GROWTH_STAGES` | array | `[:seed, :sprout, :vegetative, :budding, :bloom, :dormant]` |
| `PLANT_TYPES` | array | `[:concept, :theory, :insight, :belief, :intention, :memory, :intuition, :analogy]` |
| `MAX_PLANTS` | 50 | Plant cap |
| `GROWTH_RATE` | per-season hash | `:spring => 0.08`, `:summer => 0.10`, `:autumn => 0.05`, `:winter => 0.01` |
| `IDEAL_TEMPERATURE` | 0.65 | Optimal temperature for growth quality |
| `IDEAL_HUMIDITY` | 0.7 | Optimal humidity |
| `IDEAL_LIGHT` | 0.75 | Optimal light level |
| `CONDITION_LABELS` | nested hash | Labels for temperature, humidity, light levels |
| `CONDITION_WEIGHTS` | hash | `temperature: 0.4, humidity: 0.3, light: 0.3` |
| `STAGE_ADVANCE_THRESHOLD` | 0.65 | Minimum quality to advance to next stage |
| `MIN_QUALITY_FOR_GROWTH` | 0.40 | Minimum quality required for any growth |
| `HARVESTABLE_STAGE` | `:bloom` | Stage at which plants can be harvested |

## Helpers

### `Plant`

A cognitive idea growing under controlled conditions.

- `initialize(plant_type:, domain:, content:, quality: 0.5, plant_id: nil)`
- `grow!(rate, quality)` — advances growth; stage advances when growth crosses threshold and quality >= `STAGE_ADVANCE_THRESHOLD`
- `harvestable?` — stage == `:bloom`
- `dormant?`
- `growth_label`, `quality_label`
- `to_h`

### `GreenhouseEngine`

- `create_plant(plant_type:, domain:, content:)` — returns `{ created:, plant_id:, plant: }` or capacity error
- `plant_in_greenhouse(plant_id:)` — marks plant as active in greenhouse (separate from creation)
- `grow_all!` — applies season's growth rate to all qualifying plants; skips plants where environment quality < `MIN_QUALITY_FOR_GROWTH`
- `adjust_environment(temperature: nil, humidity: nil, light: nil)` — updates environmental variables; recalculates overall quality
- `cycle_season` — advances to next season in cycle; auto-adjusts temperature/humidity/light to seasonal defaults
- `harvest(plant_id:)` — removes harvestable plant; returns plant data
- `greenhouse_report` — full stats including season, environment quality, stage distribution

## Runners

**Module**: `Legion::Extensions::CognitiveGreenhouse::Runners::CognitiveGreenhouse`

Uses `extend self` pattern.

| Method | Key Args | Returns |
|---|---|---|
| `plant_idea` | `plant_type:`, `domain:`, `content:` | `{ success:, plant_id:, plant: }` |
| `tend_greenhouse` | — | `{ success:, grown: }` — runs grow_all! |
| `adjust_environment` | `temperature: nil`, `humidity: nil`, `light: nil` | `{ success:, environment: }` |
| `advance_season` | — | `{ success:, season:, environment: }` |
| `harvest_ideas` | — | `{ success:, harvested: [...] }` |
| `greenhouse_status` | — | `{ success:, report: }` |

Private: `greenhouse(engine)` — memoized `GreenhouseEngine`. Logs via `log_debug` helper.

## Integration Points

- **`lex-cognitive-garden`**: Garden is open-air and unbounded; greenhouse is controlled and capacity-capped (50 plants). Greenhouse is suitable for high-value concepts requiring precise conditions; garden for broader cultivation.
- **`lex-cognitive-genesis`**: Harvested bloom-stage plants are prime candidates for genesis seed input. The greenhouse accelerates concept maturation before genesis processing.
- **`lex-memory`**: Harvested concepts should be stored as semantic traces in lex-memory immediately after harvest.

## Development Notes

- `grow_all!` applies the current season's growth rate but only when environment quality exceeds `MIN_QUALITY_FOR_GROWTH` (0.40). In poor conditions (e.g., winter with low quality), plants do not grow.
- `cycle_season` wraps around after `:winter` back to `:spring`. The auto-adjusted environmental values reflect the season's characteristic conditions.
- `harvest` is destructive — it removes the plant from the engine's tracking. The returned hash is the only record after harvest.
- In-memory only.

---

**Maintained By**: Matthew Iverson (@Esity)
