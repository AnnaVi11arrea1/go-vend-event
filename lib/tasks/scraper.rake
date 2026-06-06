namespace :scraper do
  desc "Run all scrapers dynamically"
  task all: :environment do
    require Rails.root.join('lib/scrapers/scraper_runner.rb')
    Scrapers::ScraperRunner.run_all
  end

  desc "Run scrapers during deploy bootstrap"
  task deploy: :environment do
    # Allow this wrapper to run reliably even when called multiple times in one process.
    Rake::Task["scraper:all"].reenable
    Rake::Task["scraper:all"].invoke
  end

  desc "Run scrapers on monthly schedule"
  task monthly: :environment do
    # Allow this wrapper to run reliably even when called multiple times in one process.
    Rake::Task["scraper:all"].reenable
    Rake::Task["scraper:all"].invoke
  end
end
