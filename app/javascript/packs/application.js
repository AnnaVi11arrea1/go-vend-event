
var FusionCharts = require("src/fusioncharts/fusioncharts");

// Require charts from fusioncharts
var Charts = require("src/fusioncharts/fusioncharts.charts");

// Require export module from fusioncharts
var ExcelExport = require("src/fusioncharts/fusioncharts.excelexport");

// Require theme from fusioncharts
var FusionTheme = require("src/fusioncharts/themes/fusioncharts.theme.fusion");

// Add charts and themes and export module as dependency
Charts(FusionCharts);
FusionTheme(FusionCharts);
ExcelExport(FusionCharts);
