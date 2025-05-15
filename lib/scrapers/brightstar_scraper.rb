require 'faraday'
require 'faraday/gzip'
require 'nokogiri'

# Hello!

module Scrapers
  class BrightstarScraper
    def self.run
      conn = Faraday.new(
        url: 'https://www.brightstar-event.com',
        headers: { 
          'Content-Type' => 'application/json',
          'User-Agent' => 'GoScrape' # Agent can be whatever
        }
      ) do |f|
        f.request :gzip # Enable gzip compression for requests
      end

      # GET
      res = conn.get('/')
      doc = Nokogiri::HTML(res.body)

            # Get only h5 elements inside .elementor-widget-container
      events = doc.css('li')
      events.each do |event|
        date = event.at_css(".X9LBpm")&.text&.strip
        event_name = event.at_css('.sxJv9vi')&.text&.strip
        event_link = event.at_css('a')&.[]('href')

        next if event_name.blank? || date.blank? || event_link.blank?

        event = Event.create(
          name: event_name,
          started_at: date,
          application_link: event_link,
          host_id: 1
        )

        if event.persisted?
            puts "Date: #{date}"
            puts "Event: #{event_name}"
            puts "Link: #{event_link}"
        else
          puts "Failed to create event: #{event.errors.full_messages.join(', ')}"
        end
      end
    end
  end
end
