namespace :scraper do
  desc 'Scrape events from chicagoevents.com'
  task chicago_events: :environment do
    require Rails.root.join('lib/scrapers/chicago_events_scraper.rb')
    Scrapers::ChicagoEventsScraper.run
  end
end
