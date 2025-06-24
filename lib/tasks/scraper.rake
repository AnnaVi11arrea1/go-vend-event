namespace :scraper do
  desc "Run all scrapers dynamically"
  task all: :environment do
    require Rails.root.join('lib/scrapers/scraper_runner.rb')
    Scrapers::ScraperRunner.run_all
  end
end
