// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import Rails from "@rails/ujs";
Rails.start();

import { Turbo } from "@hotwired/turbo-rails";
import "chartkick";
import "Chart.bundle";
import jquery from "jquery";
import "./controllers";

window.$ = window.jQuery = jquery;

Turbo.session.drive = false;
