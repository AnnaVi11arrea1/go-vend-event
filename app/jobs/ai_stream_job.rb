class AiStreamJob < ApplicationJob
  def perform(chat_id, query)
    chat = Chat.find(chat_id)
    service = AlgoliaSearchService.new

    service.ask(query) do |chunk|
      # Broadcast each chunk to the specific chat channel
      Turbo::StreamsChannel.broadcast_append_to(
        "chat_#{chat.id}",
        target: "chat_content_#{chat.id}",
        html: chunk
      )
    end
  end
end
