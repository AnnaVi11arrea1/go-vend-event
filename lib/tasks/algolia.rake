namespace :algolia do
  desc "Reindex all events in Algolia"
  task reindex: :environment do
    puts "🔄 Reindexing Events in Algolia..."
    
    begin
      Event.reindex!
      puts "✅ Successfully reindexed #{Event.count} events"
    rescue StandardError => e
      puts "❌ Error reindexing: #{e.message}"
      puts e.backtrace.first(5)
    end
  end

  desc "Clear and reindex all events in Algolia"
  task clear_and_reindex: :environment do
    puts "🗑️  Clearing Algolia index..."
    
    begin
      Event.clear_index!
      puts "✅ Index cleared"
      
      puts "🔄 Reindexing Events..."
      Event.reindex!
      puts "✅ Successfully reindexed #{Event.count} events"
    rescue StandardError => e
      puts "❌ Error: #{e.message}"
      puts e.backtrace.first(5)
    end
  end
end
