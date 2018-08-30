PERF_CHECK_CONFIG =
  YAML.load(File.open('config/perf_check_ci.yml')).with_indifferent_access[Rails.env]
