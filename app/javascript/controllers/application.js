import { Application } from "@hotwired/stimulus";
import TabsController from "./tabs_controller";

const application = Application.start();
application.register("tabs", TabsController);

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
