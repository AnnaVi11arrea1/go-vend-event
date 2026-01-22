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
    const resetBtn = this.containerTarget.querySelector(".ais-Chat-reset")
    if (resetBtn) resetBtn.click()
  }

  submitChat() {
    const submitBtn = this.containerTarget.querySelector(".ais-Chat-submit")
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
    const searchClient = algoliasearch(
      this.appIdValue,
      this.searchKeyValue
    );

    const search = instantsearch({ searchClient });

    search.addWidgets([
      chat({
        container: '#chat-widget-container',
        agentId: '97f69bc5-115e-4234-9fd2-2a13200eebfe',
        // Implementing transport as an object to avoid external class dependencies
        transport: {
          api: 'https://mcp.us.algolia.com/1/8_VwMrM0dXIKCrJOTE1KNkoztkg1M001Nk01NDBMMUkzszBOSTRNMk9MSrN2LUvNK7E2NDezsDQzMTQyBwA/mcp',
          headers: () => ({
            Authorization: `Bearer ${this.authTokenValue}`,
            'X-User-ID': this.userIdValue,
          }),
          body: () => ({
            sessionId: this.sessionIdValue,
          }),
          credentials: () => 'include',
        },
        templates: {
          // Hiding default buttons to move them to header
          submit: () => '',
          reset: () => '',
          retry: () => '',
          copy: () => '',
          feedbackLike: () => '',
          feedbackDislike: () => ''
        },
        tools: {
          'addToChat': {
            templates: {
              layout: ({
                // the current message for the tool
                message,
                // the current InstantSearch UI state (query, page, refinements, etc.)
                indexUiState,
                // function to update the InstantSearch UI state
                setIndexUiState,
                // function to add a result from the tool to the chat
                addToolResult
              }, { html }) => html`<div>Tool: addToChat</div>`
            },
            onToolCall: ({ addToolResult }) =>
              addToolResult({ output: { text: 'result' } })
          }
        }
      })
    ]);

    search.start();
  }
}
