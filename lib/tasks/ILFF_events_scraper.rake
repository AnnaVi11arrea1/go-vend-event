namespace :scraper do
  desc 'Scrape events from illinoisfairsandfestivals.net'
  task ILFF_events: :environment do
    require Rails.root.join('lib/scrapers/ILFF_events_scraper.rb')
    Scrapers::ChicagoEventsScraper.run
  end
end
