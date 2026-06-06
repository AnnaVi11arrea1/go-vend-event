class OllamaService
  require 'net/http'
  require 'json'

  def initialize
    @api_url = ENV['OLLAMA_URL'] || ENV['OLLAMA_API_URL'] || 'http://localhost:11434'
    @model = ENV['OLLAMA_MODEL'] || 'llama3.2:1b'
    @num_ctx = ENV.fetch('OLLAMA_NUM_CTX', '1024').to_i
    @num_predict = ENV.fetch('OLLAMA_NUM_PREDICT', '384').to_i
    @temperature = ENV.fetch('OLLAMA_TEMPERATURE', '0.3').to_f
  end

  def chat(user_message, events_context = nil)
    uri = URI("#{@api_url}/api/generate")
    
    # Build the prompt with context
    prompt = build_prompt(user_message, events_context)
    
    request_body = {
      model: @model,
      prompt: prompt,
      options: {
        num_ctx: @num_ctx,
        num_predict: @num_predict,
        temperature: @temperature
      },
      stream: false
    }.to_json

    response = Net::HTTP.post(
      uri,
      request_body,
      'Content-Type' => 'application/json'
    )

    if response.is_a?(Net::HTTPSuccess)
      result = JSON.parse(response.body)
      result['response']
    else
      raise "Ollama API error: #{response.code} - #{response.body}"
    end
  rescue StandardError => e
    Rails.logger.error("Ollama Service Error: #{e.message}")
    "I'm having trouble connecting to my AI assistant. Please make sure Ollama is running and try again."
  end

  private

  def build_prompt(user_message, events_context)
    system_prompt = <<~PROMPT
      You are a helpful assistant for a vendor events platform called goVend.
      Your job is to help users find events where they can vend their products.
      
      Be friendly, concise, and helpful. When you have event data, present it clearly.
      If no events match, suggest broadening the search or checking back later.
    PROMPT

    if events_context.present?
      "#{system_prompt}\n\nAvailable events:\n#{events_context}\n\nUser question: #{user_message}\n\nPlease provide a helpful response based on the available events."
    else
      "#{system_prompt}\n\nUser question: #{user_message}\n\nNote: No specific events were found matching this query. Provide general help or suggest how to search."
    end
  end
end
