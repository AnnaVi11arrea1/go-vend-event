module Scrapers
  class ScraperRunner
    # A list of all scraper filenames without `.rb` extension
    SCRAPERS = %w[
      chicago_events_scraper
      AZFF_events_scraper
      ARFF_events_scraper
      ALFF_events_scraper
      COFF_events_scraper
      CAFF_events_scraper
      GAFF_events_scraper
      IDFF_events_scraper
      ILFF_events_scraper
      INFF_events_scraper
      IAFF_events_scraper
      KSFF_events_scraper
      LAFF_events_scraper
      MNFF_events_scraper
      MTFF_events_scraper
      MIFF_events_scraper
      MSFF_events_scraper
      MOFF_events_scraper
      NEFF_events_scraper
      NVFF_events_scraper
      NMFF_events_scraper
      NDFF_events_scraper
      NYFF_events_scraper
      SDFF_events_scraper
      TNFF_events_scraper
      TXFF_events_scraper
      KYFF_events_scraper
      OHFF_events_scraper
      ORFF_events_scraper
      UTFF_events_scraper
      WAFF_events_scraper
      WYFF_events_scraper
      hometown_vendor_scraper
      chicago_artisan_scraper
      brightstar_scraper
      amdur_events_scraper
    ]

    def self.run_all
      SCRAPERS.each do |file_name|
        begin
          require Rails.root.join("lib/scrapers/#{file_name}")
          class_name = file_name.camelize
          klass = Scrapers.const_get(class_name)
          puts "Running #{class_name}..."
          klass.run
        rescue LoadError, NameError => e
          puts "❌ Failed to run #{file_name}: #{e.class} - #{e.message}"
        end
      end
    end
  end
end
