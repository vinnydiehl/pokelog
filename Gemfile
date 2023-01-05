source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.4"
gem "rails", "~> 7.0.4"

# The original asset pipeline for Rails
gem "sprockets-rails"

# Use PostgreSQL as the database for Active Record
gem "pg", "~> 1.4.5"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Sass to process CSS
gem "sassc-rails"

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem "poke-api-v2"
  gem "web-console"
end

group :test do
  gem "capybara", "~> 3.38"
  gem "capybara-selenium", "~> 0.0.6"
  gem "rspec", "~> 3.12"
  gem "rspec-rails", "~> 6.0"
  gem "selenium-webdriver", "~> 4.1"
end

gem "active_hash", "~> 3.1"
gem "google_sign_in", "~> 1.2"
gem "haml", "~> 6.1"
gem "repost", "~> 0.4"
