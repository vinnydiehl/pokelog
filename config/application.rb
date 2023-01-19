require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile
Bundler.require(*Rails.groups)

module PokeLog
  class Application < Rails::Application
    config.load_defaults 7.0
    config.eager_load_paths += [Rails.root.join("lib")]
    config.exceptions_app = self.routes

    # Don't generate specs
    config.generators { |g| g.test_framework nil }
  end
end
