import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tabs"
export default class extends Controller {
  static targets = ["btn", "tab"]
  static values = { activeClass: String, defaultTab: String };
  connect() {
    console.log("Connected to tabs controller");
    this.selectById(this.defaultTabValue || this.tabTargets[0]?.id);
  }

  select(event) {
    const selectedTab = event.target.id;

    this.tabTargets.forEach((tab) => {
      tab.classList.toggle("active", tab.id === selectedTab);
    });

    const tabId = event.target.id;
    this.selectById(tabId);
  }
  // switch between tabs
  // add to your buttons: data-action="click->tabs#select"
  selectById(tabId) {
    const activeClass = this.activeClassValue || "active"; // Default to 'active' if not provided

    this.btnTargets.forEach((btn) => {
      const isActive = btn.id === tabId;
      btn.classList.toggle(activeClass, isActive);
    });

    this.tabTargets.forEach((tab) => {
      const isActive = tab.id === tabId;
      tab.classList.toggle("hidden", !isActive);
    });
  }
}
