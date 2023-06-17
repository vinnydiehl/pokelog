# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/util", under: "util"

pin "anychart-radar", to: "anychart_radar.min.js", preload: true
pin "nouislider", to: "nouislider.min.js", preload: true
pin "slip", to: "slip.js", preload: true
