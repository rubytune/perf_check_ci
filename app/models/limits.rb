# frozen_string_literal: true

# Returns the reporting limits configured in the application for various
# measurements.
class Limits
  attr_accessor :relative_performance
  attr_accessor :maximum_latency
  attr_accessor :maximum_query_count

  def initialize(attributes)
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
end
