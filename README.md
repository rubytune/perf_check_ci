# Perf Check CI

[Perf Check](https://github.com/rubytune/perf_check) is a command line tool to run performance tests on running web applications. Perf Check CI is a web application to manage Perf Check jobs. You interact with Perf Check CI either through a browser directly or by issuing command in GitHub branches and issues.

## Development

Perf Check CI requires **Redis** and **Postgres** to run. You should also install a recent version of **Ruby** and **Yarn**. Once you have these in place you can run the setup script to perform all relevant setup steps.

    bin/setup

If you want to customize any settings you can change `config/database.yml` and `config/perf_check_ci.yml`. 

Run Sidekiq and a Rails server to access the application:

    bundle exec sidekiq -q perf_check -q logs
    rails server

The Rails command will print instructions on how to access the application.

## Automated testing

Run automated tests through the rails command.

    rails test

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  _____    ______   _____    ______      _____   _    _   ______    _____   _  __     _____   _____
 |  __ \  |  ____| |  __ \  |  ____|    / ____| | |  | | |  ____|  / ____| | |/ /    / ____| |_   _|
 | |__) | | |__    | |__) | | |__      | |      | |__| | | |__    | |      | ' /    | |        | |
 |  ___/  |  __|   |  _  /  |  __|     | |      |  __  | |  __|   | |      |  <     | |        | |
 | |      | |____  | | \ \  | |        | |____  | |  | | | |____  | |____  | . \    | |____   _| |_
 |_|      |______| |_|  \_\ |_|         \_____| |_|  |_| |______|  \_____| |_|\_\    \_____| |_____|

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
