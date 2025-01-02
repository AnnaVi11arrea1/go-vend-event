// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import Rails from "@rails/ujs";
Rails.start();

import { Turbo } from "@hotwired/turbo-rails";
import "chartkick";
import "Chart.bundle";

import "./controllers";
import * as $ from "jquery";
window.$ = $; // Make jQuery globally accessible, if necessary.
window.jQuery = $;


Turbo.session.drive = false;
