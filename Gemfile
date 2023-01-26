source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.0"
gem "rails", "~> 7.0.4"

# The original asset pipeline for Rails
gem "sprockets-rails"

# Use PostgreSQL as the database for Active Record
gem "pg", "~> 1.4.5"

# Use the Puma web server
gem "puma", "~> 5.0"

# Use JavaScript with ESM import maps
gem "importmap-rails"

# JavaScript frameworks for single page app functions
gem "turbo-rails", "~> 1.3"
gem "stimulus-rails", "~> 1.2"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "~> 1.16", require: false

# Use SCSS
gem "sassc-rails", "~> 2.1"

group :production do
  # JS minification
  gem "mini_racer", "~> 0.6"
  gem "terser", "~> 1.1"

  # Force domain name
  gem "rack-canonical-host", "~> 1.1"
end

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem "poke-api-v2"
  gem "web-console"
end

group :test do
  gem "rspec", "~> 3.12"
  gem "rspec-rails", "~> 6.0"
  gem "fuubar", "~> 2.0"

  gem "capybara", "~> 3.38"
  gem "capybara-selenium", "~> 0.0.6"
  gem "selenium-webdriver", "~> 4.1"
end

gem "active_hash", "~> 3.1"
gem "google_sign_in", "~> 1.2"
gem "haml", "~> 6.1"
gem "haml-rails", "~> 2.0"
gem "repost", "~> 0.4"
