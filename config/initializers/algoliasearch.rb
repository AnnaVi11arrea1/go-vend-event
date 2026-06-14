# Only configure Algolia when both the gem and credentials are available.
algolia_enabled = defined?(Algolia::SearchClient) &&
  ENV['ALGOLIA_APP_ID'].present? &&
  ENV['ALGOLIA_API_KEY'].present?

if algolia_enabled
  ALGOLIA_CLIENT = Algolia::SearchClient.create(
    ENV['ALGOLIA_APP_ID'],
    ENV['ALGOLIA_API_KEY']
  )
  Rails.logger.info('Algolia Search configured')
elsif !defined?(Algolia::SearchClient)
  Rails.logger.info('Algolia gem not loaded; skipping Algolia setup')
else
  Rails.logger.warn('Algolia credentials not found in environment')
end
