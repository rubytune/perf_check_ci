# frozen_string_literal: true

module Support
  # Handles application directory setup for a test run.
  module AppSetup
    # Returns the directory that holds all the app bundles.
    def self.bundle_dir
      File.join(
        ActiveSupport::TestCase.fixture_path,
        'files', 'bundles'
      )
    end

    # Returns a path to a tarball for the specified bundle name.
    def self.app_bundle_path(name)
      File.join(bundle_dir, "#{name}.tar.bz2")
    end

    # Minimal is a Rails app with just one controller that sleeps random amount
    # of time and then returns a 200.
    def self.minimal_bundle_path
      app_bundle_path('minimal')
    end

    def minimal_app_dir
      Support::AppSetup.minimal_app_dir
    end

    def app_bundle_path(name)
      Support::AppSetup.app_bundle_path(name)
    end

    # Yields a temporary directory and automatically cleans it up when the
    # block ends.
    def using_tmpdir(&block)
      Dir.mktmpdir('perf-check', &block)
    end

    # Unpacks an app, changes directory to that app, and calls the block.
    def using_app(name)
      using_tmpdir do |app_dir|
        PerfCheck::App.new(
          bundle_path: Support::AppSetup.app_bundle_path(name),
          app_dir: app_dir
        ).unpack
        yield app_dir
      end
    end

    # Temporarily changes the APP_CONFIG.
    def with_app_config(variables)
      before = APP_CONFIG.slice(*variables.keys)
      APP_CONFIG.update(variables)
      begin
        yield
      ensure
        APP_CONFIG.update(before)
      end
    end
  end
end
