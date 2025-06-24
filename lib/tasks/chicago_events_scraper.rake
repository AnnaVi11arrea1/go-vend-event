namespace :scraper do
  # to add a scraper, make a new scraper file and then add it here so you can call it.
  # run scraprs like: rake scraper:KSFF_events
  desc 'Scrape events from chicagoevents.com'
  task chicago_events: :environment do
    require Rails.root.join('lib/scrapers/chicago_events_scraper.rb')
    Scrapers::ChicagoEventsScraper.run
  end

  desc 'Scrape events from amdurproductions.com'
  task amdur_events: :environment do
    require Rails.root.join('lib/scrapers/amdur_events_scraper.rb')
    Scrapers::AmdurEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # ARIZONA users will still have to manually search google to find event page unless they login with an account
  task AZFF_events: :environment do
    require Rails.root.join('lib/scrapers/AZFF_events_scraper.rb')
    Scrapers::AZFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # ARKANSAS users will still have to manually search google to find event page unless they login with an account
  task ARFF_events: :environment do
    require Rails.root.join('lib/scrapers/ARFF_events_scraper.rb')
    Scrapers::ARFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # ALABAMA users will still have to manually search google to find event page unless they login with an account
  task ALFF_events: :environment do
    require Rails.root.join('lib/scrapers/ALFF_events_scraper.rb')
    Scrapers::ALFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # COLORADO users will still have to manually search google to find event page unless they login with an account
  task COFF_events: :environment do
    require Rails.root.join('lib/scrapers/COFF_events_scraper.rb')
    Scrapers::COFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # CALIFORNIA users will still have to manually search google to find event page unless they login with an account
  task CAFF_events: :environment do
    require Rails.root.join('lib/scrapers/CAFF_events_scraper.rb')
    Scrapers::CAFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # GEORGIA users will still have to manually search google to find event page unless they login with an account
  task GAFF_events: :environment do
    require Rails.root.join('lib/scrapers/GAFF_events_scraper.rb')
    Scrapers::GAFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # IDAHO users will still have to manually search google to find event page unless they login with an account
  task IDFF_events: :environment do
    require Rails.root.join('lib/scrapers/IDFF_events_scraper.rb')
    Scrapers::IDFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # ILLINOIS users will still have to manually search google to find event page unless they login with an account
  task ILFF_events: :environment do
    require Rails.root.join('lib/scrapers/ILFF_events_scraper.rb')
    Scrapers::ILFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # INDIANA users will still have to manually search google to find event page unless they login with an account
  task INFF_events: :environment do
    require Rails.root.join('lib/scrapers/INFF_events_scraper.rb')
    Scrapers::INFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # IOWA users will still have to manually search google to find event page unless they login with an account
  task IAFF_events: :environment do
    require Rails.root.join('lib/scrapers/IAFF_events_scraper.rb')
    Scrapers::IAFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # KANSAS users will still have to manually search google to find event page unless they login with an account
  task KSFF_events: :environment do
    require Rails.root.join('lib/scrapers/KSFF_events_scraper.rb')
    Scrapers::KSFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # LOUISIANA users will still have to manually search google to find event page unless they login with an account
  task LAFF_events: :environment do
    require Rails.root.join('lib/scrapers/LAFF_events_scraper.rb')
    Scrapers::LAFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # MINNESOTA users will still have to manually search google to find event page unless they login with an account
  task MNFF_events: :environment do
    require Rails.root.join('lib/scrapers/MNFF_events_scraper.rb')
    Scrapers::MNFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # MONTANA users will still have to manually search google to find event page unless they login with an account
  task MTFF_events: :environment do
    require Rails.root.join('lib/scrapers/MTFF_events_scraper.rb')
    Scrapers::MTFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # MICHIGAN users will still have to manually search google to find event page unless they login with an account
  task MIFF_events: :environment do
    require Rails.root.join('lib/scrapers/MIFF_events_scraper.rb')
    Scrapers::MIFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # MISSISSIPPI users will still have to manually search google to find event page unless they login with an account
  task MSFF_events: :environment do
    require Rails.root.join('lib/scrapers/MSFF_events_scraper.rb')
    Scrapers::MSFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # MISSOURI users will still have to manually search google to find event page unless they login with an account
  task MOFF_events: :environment do
    require Rails.root.join('lib/scrapers/MOFF_events_scraper.rb')
    Scrapers::MOFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # NEBRASKA users will still have to manually search google to find event page unless they login with an account
  task NEFF_events: :environment do
    require Rails.root.join('lib/scrapers/NEFF_events_scraper.rb')
    Scrapers::NEFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # NEVADA users will still have to manually search google to find event page unless they login with an account
  task NVFF_events: :environment do
    require Rails.root.join('lib/scrapers/NVFF_events_scraper.rb')
    Scrapers::NVFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # NEW MEXICO users will still have to manually search google to find event page unless they login with an account
  task NMFF_events: :environment do
    require Rails.root.join('lib/scrapers/NMFF_events_scraper.rb')
    Scrapers::NMFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # NORTH DAKOTA users will still have to manually search google to find event page unless they login with an account
  task NDFF_events: :environment do
    require Rails.root.join('lib/scrapers/NDFF_events_scraper.rb')
    Scrapers::NDFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # NEW YORK users will still have to manually search google to find event page unless they login with an account
  task NYFF_events: :environment do
    require Rails.root.join('lib/scrapers/NYFF_events_scraper.rb')
    Scrapers::NYFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # SOUTH DAKOTA users will still have to manually search google to find event page unless they login with an account
  task SDFF_events: :environment do
    require Rails.root.join('lib/scrapers/SDFF_events_scraper.rb')
    Scrapers::SDFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # TENNESSEE users will still have to manually search google to find event page unless they login with an account
  task TNFF_events: :environment do
    require Rails.root.join('lib/scrapers/TNFF_events_scraper.rb')
    Scrapers::TNFFEventsScraper.run
  end
  
  desc 'Scrape events from fairsandfestivals.net'
  # TEXAS users will still have to manually search google to find event page unless they login with an account
  task TXFF_events: :environment do
    require Rails.root.join('lib/scrapers/TXFF_events_scraper.rb')
    Scrapers::TXFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # KENTUCKY users will still have to manually search google to find event page unless they login with an account
  task KYFF_events: :environment do
    require Rails.root.join('lib/scrapers/KYFF_events_scraper.rb')
    Scrapers::KYFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # OHIO users will still have to manually search google to find event page unless they login with an account
  task OHFF_events: :environment do
    require Rails.root.join('lib/scrapers/OHFF_events_scraper.rb')
    Scrapers::OHFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # OREGON users will still have to manually search google to find event page unless they login with an account
  task ORFF_events: :environment do
    require Rails.root.join('lib/scrapers/ORFF_events_scraper.rb')
    Scrapers::ORFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # UTAH users will still have to manually search google to find event page unless they login with an account
  task UTFF_events: :environment do
    require Rails.root.join('lib/scrapers/UTFF_events_scraper.rb')
    Scrapers::UTFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # WASHINGTON users will still have to manually search google to find event page unless they login with an account
  task WAFF_events: :environment do
    require Rails.root.join('lib/scrapers/WAFF_events_scraper.rb')
    Scrapers::WAFFEventsScraper.run
  end

  desc 'Scrape events from fairsandfestivals.net'
  # WYOMING users will still have to manually search google to find event page unless they login with an account
  task WYFF_events: :environment do
    require Rails.root.join('lib/scrapers/WYFF_events_scraper.rb')
    Scrapers::WYFFEventsScraper.run
  end

  desc 'Scrape events from chicagoevents.com'
  task chicago_events: :environment do
    require Rails.root.join('lib/scrapers/chicago_events_scraper.rb')
    Scrapers::ChicagoEventsScraper.run
  end
  
  desc 'Scrape events from hometownvendormarket.com'
  task hometown_vendor: :environment do
    require Rails.root.join('lib/scrapers/hometown_vendor_scraper.rb')
    Scrapers::HometownVendorScraper.run
    # bin/rails scraper:hometown_vendor 
  end

  desc 'Scrape events from chicagoartisanmarket.com'
  task chicago_artisan: :environment do
    require Rails.root.join('lib/scrapers/chicago_artisan_scraper.rb')
    Scrapers::ChicagoArtisanScraper.run
    # bin/rails scraper:chicago_artisan
  end

  desc 'Scrape events from bright-star.com'
  task brightstar: :environment do
    require Rails.root.join('lib/scrapers/brightstar_scraper.rb')
    Scrapers::BrightstarScraper.run
    # bin/rails scraper:chicago_artisan
  end
end
