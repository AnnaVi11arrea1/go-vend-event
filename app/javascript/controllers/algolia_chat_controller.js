import { Controller } from "@hotwired/stimulus"
import { marked } from 'marked'

// Connects to data-controller="algolia-chat"
export default class extends Controller {
  static targets = ["container", "button", "messages", "input"]

  connect() {
    this.messages = []
    this.setupChatUI()
  }

  toggle() {
    this.containerTarget.classList.toggle("d-none")
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
    this.messages = []
    this.messagesTarget.innerHTML = ''
    console.log("✨ Chat reset")
  }

  copyChat() {
    const lastAIMessage = this.messages.filter(m => m.role === 'assistant').pop()
    if (lastAIMessage) {
      navigator.clipboard.writeText(lastAIMessage.content)
      alert("Last response copied to clipboard!")
    }
  }

  async submitChat() {
    const input = this.inputTarget
    const message = input.value.trim()

    if (!message) return

    console.log("📤 Sending message:", message)

    // Add user message to UI
    this.addMessage('user', message)
    input.value = ''

    // Show loading indicator
    const loadingId = this.addMessage('assistant', '...', true)

    try {
      // Send to our Rails backend
      const response = await fetch('/chat/message', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({ message })
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const data = await response.json()
      console.log("📥 Received response:", data)

      // Remove loading indicator
      this.removeMessage(loadingId)

      // Add AI response
      this.addMessage('assistant', data.response)

      // Add events if any were found
      if (data.events && data.events.length > 0) {
        this.addEventsCard(data.events)
      }

    } catch (error) {
      console.error("❌ Chat error:", error)
      this.removeMessage(loadingId)
      this.addMessage('assistant', 'Sorry, I encountered an error. Please make sure Ollama is running and try again.')
    }
  }

  setupChatUI() {
    // Create messages container if it doesn't exist
    const chatWidget = this.containerTarget.querySelector('#chat-widget-container')
    if (chatWidget && !this.hasMessagesTarget) {
      chatWidget.innerHTML = `
        <div class="chat-messages-container" data-algolia-chat-target="messages"></div>
        <div class="chat-input-container">
          <textarea 
            data-algolia-chat-target="input" 
            placeholder="Ask about events..."
            rows="3"
            class="chat-input"
          ></textarea>
          <button 
            data-action="click->algolia-chat#submitChat"
            class="chat-send-btn"
          >
            <i class="fa fa-paper-plane"></i> Send
          </button>
        </div>
      `
    }
  }

  addMessage(role, content, isLoading = false) {
    const messageId = `msg-${Date.now()}-${Math.random()}`
    const messageDiv = document.createElement('div')
    messageDiv.id = messageId
    messageDiv.className = `chat-message chat-message--${role}`

    // Parse markdown for assistant messages
    const formattedContent = (role === 'assistant' && !isLoading)
      ? marked.parse(content)
      : content

    messageDiv.innerHTML = `
      <div class="chat-message-content ${isLoading ? 'loading' : ''}">
        ${formattedContent}
      </div>
    `

    this.messagesTarget.appendChild(messageDiv)
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight

    if (!isLoading) {
      this.messages.push({ role, content })
    }

    return messageId
  }

  removeMessage(messageId) {
    const element = document.getElementById(messageId)
    if (element) {
      element.remove()
    }
  }

  addEventsCard(events) {
    const eventsHtml = events.map((event, index) => `
      <div class="event-card-item">
        <div class="event-number">${index + 1}</div>
        <div class="event-details">
          <a href="${event.url}" class="event-name-link" target="_blank">
            ${event.name}
          </a>
          <div class="event-location">
            📍 ${event.city ? event.city + ', ' : ''}${event.state || event.address}
          </div>
          <div class="event-date">
            📅 ${event.started_at || 'Date TBD'}
          </div>
        </div>
      </div>
    `).join('')

    const eventsCard = `
      <div class="events-list-card">
        <div class="events-list-header">
          Found ${events.length} Event${events.length !== 1 ? 's' : ''}
        </div>
        <div class="events-list-body">
          ${eventsHtml}
        </div>
      </div>
    `

    const messageDiv = document.createElement('div')
    messageDiv.className = 'chat-message chat-message--events'
    messageDiv.innerHTML = eventsCard

    this.messagesTarget.appendChild(messageDiv)
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  // Handle Enter key to send
  inputTargetConnected(element) {
    element.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault()
        this.submitChat()
      }
    })
  }
}
