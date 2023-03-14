# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

# Force poke-log.herokuapp.com to www.pokelog.net (or whatever
# that environment variable is set to)
if Rails.env.production? && ENV["CANONICAL_HOST"]
  require "rack/canonical_host"
  use Rack::CanonicalHost, ENV["CANONICAL_HOST"]
end

run Rails.application
Rails.application.load_server
