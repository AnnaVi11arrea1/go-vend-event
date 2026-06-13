# Only configure Algolia if credentials are present
if ENV['ALGOLIA_APP_ID'].present? && ENV['ALGOLIA_API_KEY'].present?
  ALGOLIA_CLIENT = Algolia::SearchClient.create(
    ENV['ALGOLIA_APP_ID'],
    ENV['ALGOLIA_API_KEY']
  )
  Rails.logger.info("✅ Algolia Search configured")
else
  Rails.logger.warn("⚠️ Algolia credentials not found in environment")
end
