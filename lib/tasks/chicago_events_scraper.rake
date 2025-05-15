namespace :scraper do
  desc 'Scrape events from chicagoevents.com'
  task chicago_events: :environment do
    require Rails.root.join('lib/scrapers/chicago_events_scraper.rb')
    Scrapers::ChicagoEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # login required
  # links are bad
  task ILFF_events: :environment do
    require Rails.root.join('lib/scrapers/ILFF_events_scraper.rb')
    Scrapers::ILFFEventsScraper.run
  end

    desc 'Scrape events from fairsandfestivals.net'
  # login required
  # links are bad
  task ILFF_events: :environment do
    require Rails.root.join('lib/scrapers/ILFF_events_scraper.rb')
    Scrapers::ILFFEventsScraper.run
  end

  desc 'Scrape events from chicagoevents.com'
  task chicago_events: :environment do
    require Rails.root.join('lib/scrapers/chicago_events_scraper.rb')
    Scrapers::ChicagoEventsScraper.run
  end

  desc 'Run all scrapers'
  task all: :environment do
    Rake::Task['scraper:chicago_events'].invoke
    Rake::Task['scraper:ILFF_events'].invoke
  end
end
