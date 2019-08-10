# frozen_string_literal: true

module Support
  # Handles application directory setup for a test run.
  class AppSetup
    attr_reader :app_dir
    attr_reader :bundle_path
    attr_reader :packer

    def initialize(app_dir:, bundle_path:)
      @app_dir = app_dir
      @bundle_path = bundle_path
      @packer = Support::Packer.new(app_dir: app_dir, bundle_path: bundle_path)
    end

    def gemfile
      File.join(app_dir, 'Gemfile')
    end

    def run
      packer.unpack
      unless File.exist?(gemfile)
        raise(
          "The unpacked bundle #{bundle_path} does not contain a Gemfile " \
          "so it can't be used as a test application."
        )
      end
      Minitest.after_run { FileUtils.rm_rf(app_dir) }
    end

    # Minimal is a Rails app with just one controller that sleep random amount
    # of time and then returns a 200.
    def self.minimal_bundle_path
      File.join(
        ActiveSupport::TestCase.fixture_path,
        'files', 'bundles', 'minimal.tar.bz2'
      )
    end
  end
end
