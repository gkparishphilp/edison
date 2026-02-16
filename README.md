# Edison

An A/B testing experiment framework for Rails with variant assignment, trial tracking, and statistical analysis.

See [CLAUDE.md](CLAUDE.md) for detailed architecture documentation.

## Features

- Experiment creation with configurable sampling strategies (50/50, weighted, random)
- Variant management with control variant designation
- Trial assignment via persistent client cookies
- Conversion tracking through Bunyan event integration
- Statistical confidence intervals (67% to 99.9%)
- Conversion rate calculation with time-window filtering
- URL pattern matching for experiment targeting
- Forced variant overrides for testing
- Auto-conclusion when max trials or end date reached
- Customer acquisition cost tracking per variant

## Models

| Model | Description |
|-------|-------------|
| `Experiment` | A/B test definition with sampling strategy, conversion event, and time window |
| `Variant` | Alternative content/experience within an experiment, with statistical tracking |
| `Trial` | Assignment of a client to a variant |
| `ExperimentUrlPattern` | URL patterns for targeting experiments |

## Usage

```ruby
# In views (via ApplicationHelper)
<%= edison_run_experiment('my-experiment-slug', default: 'Default content') %>

# Force a specific variant
<%= edison_run_experiment('my-experiment-slug', force_var: 'control') %>
```

## Dependencies

- `rails` >= 5.1
- `bunyan` - Event tracking (Bunyan::Event, Bunyan::Client)
- `abanalyzer` - Statistical analysis (confidence intervals)

## Integration

- **Bunyan** - Client session tracking via `clientuuid` cookie; conversion events tracked through Bunyan::Event
- **Bazaar** (in nhc-web) - OrderTrial/SubscriptionTrial link orders to experiments via EdisonOrderWorker

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
