## Usage

## Development

### Setup

1. Ensure you have Redis & Postgres installed and running.
2. `bundle install`
2. `rake db:setup`
3. `bundle exec sidekiq -q perf_check -q logs`
4. `rails s`


### Configuration

1. `cp config/perf_check_ci.yml.example config/perf_check_ci.yml`
2. `cp config/database.yml.example config/database.yml`

### Search

Need to reindex?
`PgSearch::Multisearch.rebuild(PerfCheckJob)`

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  _____    ______   _____    ______      _____   _    _   ______    _____   _  __     _____   _____
 |  __ \  |  ____| |  __ \  |  ____|    / ____| | |  | | |  ____|  / ____| | |/ /    / ____| |_   _|
 | |__) | | |__    | |__) | | |__      | |      | |__| | | |__    | |      | ' /    | |        | |
 |  ___/  |  __|   |  _  /  |  __|     | |      |  __  | |  __|   | |      |  <     | |        | |
 | |      | |____  | | \ \  | |        | |____  | |  | | | |____  | |____  | . \    | |____   _| |_
 |_|      |______| |_|  \_\ |_|         \_____| |_|  |_| |______|  \_____| |_|\_\    \_____| |_____|

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
