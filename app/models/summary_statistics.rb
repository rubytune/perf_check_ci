# frozen_string_literal: true

# Lazy transformation and computation of summary statistics over a list of
# entries.
#
#   SummaryStatistics.new(
#     [
#       {'latency' => 12},
#       {'latency' => 20}
#     ]
#   ).latency.total #=> 32
class SummaryStatistics
  # Holds a label and values for a metric and does the actual computations.
  class Metric
    attr_reader :label
    attr_reader :values

    def initialize(label, values)
      @label = label
      @values = values
    end

    delegate :length, to: '@values'
    delegate :first, to: '@values'
    delegate :min, :max, to: '@values'

    def total
      @total ||= @values.inject(0, &:+)
    end
  end

  attr_reader :measurements

  def initialize(measurements)
    @measurements = measurements
    @metric = {}
  end

  delegate :empty?, :blank?, :present?, to: '@measurements'

  def respond_to_missing?(method, include_private = false)
    metric?(method.to_s) || super
  end

  def method_missing(method)
    label = method.to_s
    if metric?(label)
      @metric[label] ||= Metric.new(label, values(label))
    else
      super
    end
  end

  def on_branch(branch)
    self.class.new(filter('branch', branch))
  end

  def on_request_path(request_path)
    self.class.new(filter('request_path', request_path))
  end

  private

  def filter(key, value)
    @measurements.select { |entry| entry[key] == value }
  end

  def metric?(label)
    return false if @measurements.blank?

    @measurements.first.key?(label)
  end

  def values(label)
    return nil if @measurements.blank?

    @measurements.map { |entry| entry[label] }
  end
end
