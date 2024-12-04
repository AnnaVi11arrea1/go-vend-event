// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import { Turbo } from "@hotwired/turbo-rails"
import "chartkick"
import "Chart.bundle"
import Rails from "@rails/ujs"
import FusionCharts from "fusioncharts";
import Charts from "fusioncharts.charts";
import ExcelExport from "fusioncharts.excelexport";
import FusionTheme from "fusioncharts.theme.fusion";
import jquery from "jquery";


// Add charts and themes and export module as dependency
Charts(FusionCharts);
FusionTheme(FusionCharts);
ExcelExport(FusionCharts);


window.jQuery = jquery;
window.$ = jquery;
Rails.start();

Turbo.session.drive = false
