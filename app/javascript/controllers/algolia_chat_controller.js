import { Controller } from "@hotwired/stimulus"
import { liteClient as algoliasearch } from 'algoliasearch/lite'
import instantsearch from 'instantsearch.js'
import { chat } from 'instantsearch.js/es/widgets'

// Connects to data-controller="algolia-chat"
export default class extends Controller {
  static targets = ["container", "button"]
  static values = {
    appId: String,
    searchKey: String,
    userId: String,
    authToken: String,
    sessionId: String
  }

  connect() {
    this.initialized = false
  }

  toggle() {
    this.containerTarget.classList.toggle("d-none")

    if (!this.initialized) {
      this.initSearch()
      this.initialized = true
    }
  }

  maximize() {
    this.containerTarget.classList.toggle("fullscreen")
    const icon = this.containerTarget.querySelector(".maximize-btn i")
    if (this.containerTarget.classList.contains("fullscreen")) {
      icon.className = "fa fa-compress"
    } else {
      icon.className = "fa fa-expand"
    }
  }

  resetChat() {
    const resetBtn = this.containerTarget.querySelector(".ais-ChatPrompt-reset")
    if (resetBtn) resetBtn.click()
  }

  submitChat() {
    const submitBtn = this.containerTarget.querySelector(".ais-ChatPrompt-submit")
    if (submitBtn) submitBtn.click()
  }

  copyChat() {
    const messages = this.containerTarget.querySelectorAll(".ais-Chat-item--agent .ais-Chat-message")
    if (messages.length > 0) {
      const lastMessage = messages[messages.length - 1].innerText
      navigator.clipboard.writeText(lastMessage)
      alert("Last response copied to clipboard!")
    }
  }

  initSearch() {
    console.log("Initializing Algolia Chat with AppID:", this.appIdValue);

    const searchClient = algoliasearch(
      this.appIdValue,
      this.searchKeyValue
    );

    const search = instantsearch({ searchClient });

    search.addWidgets([
      chat({
        container: '#chat-widget-container',
        agentId: '97f69bc5-115e-4234-9fd2-2a13200eebfe',
        transport: {
          api: 'https://mcp.us.algolia.com/1/8_VwMrM0dXIKCrJOTE1KNkoztkg1M001Nk01NDBMMUkzszBOSTRNMk9MSrN2LUvNK7E2NDezsDQzMTQyBwA/mcp',
          headers: () => ({
            'Authorization': `Bearer ${this.authTokenValue}`,
            'X-User-ID': this.userIdValue || 'anonymous',
          }),
          body: () => ({
            sessionId: this.sessionIdValue,
            userId: this.userIdValue || 'anonymous'
          }),
          credentials: 'include',
        },
        templates: {
          // Using default templates to ensure prompt area renders
        },
        tools: {
          'searchEvents': {
            templates: {
              layout: ({ message, results }, { html }) => {
                const events = results?.[0]?.hits || [];
                if (events.length === 0) return html`<div class="tool-result no-results">No events found.</div>`;

                return html`
                  <div class="tool-result">
                    <p class="tool-caption">I found these events:</p>
                    <div class="event-cards-mini">
                      ${events.map(event => html`
                        <div class="event-card-mini">
                          <span class="event-name">${event.name}</span>
                          <span class="event-date">${new Date(event.started_at).toLocaleDateString()}</span>
                        </div>
                      `)}
                    </div>
                  </div>
                `;
              }
            }
          }
        }
      })
    ]);

    search.on('render', () => {
      console.log("InstantSearch rendered");
    });

    search.start();
    console.log("InstantSearch started");
  }
}
