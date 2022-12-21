require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile
Bundler.require(*Rails.groups)

module PokeLog
  class Application < Rails::Application
    config.load_defaults 7.0
    config.eager_load_paths += [Rails.root.join("lib")]
  end
end
