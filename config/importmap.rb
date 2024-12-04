# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@rails/ujs", to: "@rails--ujs.js" # @7.1.3
pin "jquery", to: "https://code.jquery.com/jquery-3.6.0.min.js"
pin_all_from "app/javascript/helpers", under: "helpers"
pin "bootstrap" # @5.3.3
pin "chartkick", to: "chartkick.js"
pin "Chart.bundle", to: "Chart.bundle.js"
pin "@popperjs/core", to: "@popperjs--core.js" # @2.11.8
pin "fusioncharts", to: "https://cdn.fusioncharts.com/fusioncharts/latest/fusioncharts.js"
pin "fusioncharts.charts", to: "https://cdn.fusioncharts.com/fusioncharts/latest/fusioncharts.charts.js"
pin "fusioncharts.excelexport", to: "https://cdn.fusioncharts.com/fusioncharts/latest/fusioncharts.excelexport.js"
pin "fusioncharts.theme.fusion", to: "https://cdn.fusioncharts.com/fusioncharts/latest/themes/fusioncharts.theme.fusion.js"
