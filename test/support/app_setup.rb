# frozen_string_literal: true

module Support
  # Handles application directory setup for a test run.
  class AppSetup
    # Minimal is a Rails app with just one controller that sleeps random amount
    # of time and then returns a 200.
    def self.minimal_bundle_path
      File.join(
        ActiveSupport::TestCase.fixture_path,
        'files', 'bundles', 'minimal.tar.bz2'
      )
    end
  end
end
