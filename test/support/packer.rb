# frozen_string_literal: true

module Support
  # Packs and unpacks Rails projects for use in automated testing.
  class Packer
    attr_reader :bundle_path
    attr_reader :app_dir

    def initialize(bundle_path:, app_dir:)
      @bundle_path = bundle_path
      @app_dir = app_dir
    end

    def pack
      system('tar', '-cjf', bundle_path, "#{app_dir}/*")
    end

    def unpack
      system('tar', '-xjf', bundle_path, '-C', app_dir)
    end
  end
end
