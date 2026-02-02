# Cached Algolia Search Service
# This minimizes API usage by caching search results

class CachedAlgoliaSearchService
  CACHE_EXPIRY = 24.hours
  
  def initialize
    @cache = Rails.cache
  end
  
  def search(query, options = {})
    # Normalize query for consistent caching
    normalized_query = query.to_s.downcase.strip
    cache_key = "algolia:search:#{normalized_query}:#{options.to_json}"
    
    Rails.logger.info("🔍 Cached search for: #{normalized_query}")
    
    # Try cache first
    cached_result = @cache.fetch(cache_key, expires_in: CACHE_EXPIRY) do
      Rails.logger.info("💾 Cache MISS - calling Algolia API")
      
      begin
        # Only call Algolia if not in cache
        results = Event.search(normalized_query, options)
        {
          success: true,
          hits: results.to_a,
          count: results.count,
          timestamp: Time.current
        }
      rescue StandardError => e
        Rails.logger.error("❌ Algolia API error: #{e.message}")
        {
          success: false,
          error: e.message,
          hits: [],
          count: 0
        }
      end
    end
    
    if cached_result[:success]
      Rails.logger.info("✅ Returning #{cached_result[:count]} cached results")
    else
      Rails.logger.warn("⚠️ Cached error, falling back to database")
      # Fall back to database if Algolia failed
      return database_search(normalized_query, options)
    end
    
    cached_result[:hits]
  end
  
  def database_search(query, options = {})
    Rails.logger.info("🗄️ Database fallback search for: #{query}")
    
    limit = options[:hitsPerPage] || 10
    
    Event.where("LOWER(name) LIKE ? OR LOWER(city) LIKE ? OR LOWER(state) LIKE ? OR LOWER(address) LIKE ?",
                "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")
         .limit(limit)
         .to_a
  end
  
  # Preload common searches to avoid API calls
  def preload_common_searches
    common_queries = [
      'texas',
      'california',
      'florida',
      'chicago',
      'new york',
      'market',
      'festival',
      'craft fair'
    ]
    
    Rails.logger.info("🔄 Preloading #{common_queries.length} common searches...")
    
    common_queries.each do |query|
      search(query, hitsPerPage: 10)
    end
    
    Rails.logger.info("✅ Preload complete")
  end
  
  # Clear cache if needed
  def clear_cache
    Rails.logger.info("🗑️ Clearing Algolia search cache...")
    # Clear all cache keys starting with "algolia:search:"
    Rails.cache.delete_matched("algolia:search:*")
    Rails.logger.info("✅ Cache cleared")
  end
end
