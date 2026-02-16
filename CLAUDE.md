# CLAUDE.md - Edison Engine

## Purpose

Edison is an A/B testing experiment framework with variants, trials, and statistical analysis. It integrates with the Bunyan event tracking engine for conversion tracking and uses persistent client cookies for trial assignment.

**Version:** 3.3.0

## Key Models

### Edison::Experiment

- `enum status`: `archive: -1`, `draft: 0`, `active: 1`
- **Associations**: `has_many :experiment_url_patterns`, `has_many :variants`, `has_many :trials, through: :variants`
- **FriendlyId** slugged on title
- **Key attributes**: title, description, sample_type (default: '5050'), conclusion_type (default: 'control'), conversion_event, conversion_path, start_at, end_at, max_trials (default: 10000), conversion_window_days (default: 30), properties (hstore)
- **Key methods**: `concluded?`, `has_expired?(now:)`, `has_max_trials?`, `started?(now:)`

**Sample types**: `'5050'` (balanced distribution), `'weighted'` (weight-based), `'random'` (random selection)

**Conclusion types**: `'control'` (show control variant), `'winner'` (show highest conversion variant)

### Edison::Variant

- `enum status`: `archive: -1`, `draft: 0`, `active: 1`
- **Associations**: `belongs_to :experiment`, `has_many :trials`
- **Key attributes**: title, description, weight (default: 1.0), content (text/HTML), is_control (boolean), cached_participant_count, cached_conversion_count, final_participant_count, final_conversion_count, gross_margin (float), cost_of_acquiring_customers (integer cents), costs (integer cents), properties (hstore)
- **Key methods**:
  - `self.control` - Find the control variant
  - `confidence_interval(opts)` - Statistical confidence interval (supports 67%, 75%, 80%, 90%, 95%, 99%, 99.9%)
  - `conversion_rate(opts)` - Conversions / trials count
  - `conversions(opts)` - Counts via `Bunyan::Event`, filtered by experiment time window. Accepts `:event`, `:path` options.
  - `participants` - Returns Bunyan::Client records for trial participants
- **Validation**: `is_control_toggle` prevents deselecting control without replacement

### Edison::Trial

- **Associations**: `belongs_to :experiment`, `belongs_to :client` (Bunyan::Client, optional), `belongs_to :variant` (optional)
- **Key attributes**: created_url, is_forced (boolean)
- **Key method**: `generate_variant` - Assigns variant based on experiment's sample_type:
  - `'weighted'`: Weighted random sampling based on variant weights
  - `'5050'`: Assigns to variant with lowest participant count
  - `'random'`: Random selection from active variants
  - Updates variant's `cached_participant_count` after assignment

### Edison::ExperimentUrlPattern

- `belongs_to :experiment`
- Fields: url_pattern (string)

## Key Helper

### Edison::ApplicationHelper

**`edison_run_experiment(exp_id, options = {})`** - Main entry point for running experiments in views:

1. Find experiment by FriendlyId slug
2. Check for forced variant override via `force_var` option ('control' or variant ID)
3. Get or create Bunyan::Client via `clientuuid` cookie
4. Check for existing trial for this client
5. If concluded: show control, winner, or default based on conclusion_type
6. If not active/started: show default
7. Create new trial with `generate_variant` if needed
8. Return variant content as HTML

**Options**: `:default` (fallback content), `:force_var` ('control' or variant ID)

## Controllers

### Admin

- **`ExperimentAdminController`** - CRUD for experiments. Defaults start_at to now, end_at to start_at + 1 month.
- **`VariantAdminController`** - CRUD for variants. Auto-marks first variant as control. Handles control switching.
- **`ExperimentUrlPatternAdminController`** - CRUD for URL patterns.

### Concern

- **`ApplicationControllerConcern`** - Injected into host app's ApplicationController for experiment tracking

## Configuration

Minimal - no mattr_accessor configuration. Engine uses `isolate_namespace Edison`.

## Dependencies

- `rails` >= 5.1
- `bunyan` - Event tracking (Bunyan::Event, Bunyan::Client)
- `abanalyzer` - Statistical analysis (confidence intervals)

## Integration Notes

- Relies on Bunyan's `clientuuid` cookie for trial assignment
- Conversion tracking via Bunyan::Event queries
- Participant counts cached on variants (manual increment/decrement)
- Host app integration via `ApplicationControllerConcern` and `edison_run_experiment` helper
- In nhc-web: `EdisonOrderWorker` processes order conversion tracking, `Bazaar::OrderTrial` / `Bazaar::SubscriptionTrial` link orders/subscriptions to experiments
