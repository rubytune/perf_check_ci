# frozen_string_literal: true

module Support
  module Measurements
    def measurements_filename(label)
      Rails.root.join('test', 'measurements', "#{label}.yml").to_s
    end

    # Returns raw measurements from fixture files meant for integration
    # testing.
    def measurements(*labels)
      labels.inject([]) do |measurements, label|
        measurements + YAML.load_file(measurements_filename(label))
      end
    end
  end
end
