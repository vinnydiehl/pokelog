require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile
Bundler.require(*Rails.groups)

module PokeLog
  # For dynamic uptime info
  BOOTED_AT = Time.now

  NATURES = YAML.load_file("data/natures.yml")
  ITEMS = YAML.load_file("data/items.yml")

  class Application < Rails::Application
    config.load_defaults 7.0
    config.eager_load_paths += [Rails.root.join("lib")]
    config.exceptions_app = self.routes
    config.time_zone = "Eastern Time (US & Canada)"

    # Don't generate specs
    config.generators { |g| g.test_framework nil }
  end
end
