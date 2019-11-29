# frozen_string_literal: true

class Report
  # Investigates performance between two branches and returns observations about it.
  class CompareBranches
    include ActiveModel::Model

    def initialize(experiment:, reference:)
      @experiment = experiment
      @reference = reference
    end

    def title
      return if experiment.empty?

      experiment.request_path.first
    end

    def observations
      return [] if experiment.empty?

      [
        performance_observation + ' ' + performance_observation_averages,
        query_count_observation,
        maximum_latency_observation
      ].compact
    end

    private

    def limits
      @limits ||= Limits.new(APP_CONFIG[:limits])
    end

    def positive?
      experiment.latency.average < reference.latency.average
    end

    def faster?
      positive? && performance > limits.relative_performance
    end

    def slower?
      !positive? && performance > limits.relative_performance
    end

    def performance
      @performance ||= [
        experiment.latency.average, reference.latency.average
      ].sort.reverse.inject(&:/)
    end

    def reference_branch_name
      reference.measurements.first['branch']
    end

    def performance_observation
      if faster?
        "✅ #{performance.round(1)}x faster than #{reference_branch_name}"
      elsif slower?
        "❌ #{performance.round(1)}x slower than #{reference_branch_name}"
      else
        "☑️ about the same as #{reference_branch_name}"
      end
    end

    def performance_observation_averages
      "(#{experiment.latency.average.round(1)}ms vs #{reference.latency.average.round(1)}ms)"
    end

    def query_count_change
      @query_count_change ||= experiment.query_count.average - reference.query_count.average
    end

    def query_count_observation
      if query_count_change.negative?
        "☑️ reduced database queries from #{reference.query_count.average.round} to " \
        "#{experiment.query_count.average.round}!"
      elsif query_count_change.positive? && reference.query_count.max >= limits.maximum_query_count
        "❌ increased database queries from #{reference.query_count.average.round} to " \
        "#{experiment.query_count.average.round}!"
      elsif experiment.query_count.max >= limits.maximum_query_count
        "⚠️ #{experiment.query_count.max} database queries were made"
      end
    end

    def maximum_latency_observation
      return if experiment.latency.max <= limits.maximum_latency

      format('⚠️ takes over %<latency>.1f seconds', latency: limits.maximum_latency / 1000.0)
    end

    attr_reader :experiment
    attr_reader :reference
  end
end
