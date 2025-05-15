require 'faraday'
require 'faraday/gzip'
require 'nokogiri'

# Hello!

module Scrapers
  class ChicagoArtisanScraper
    def self.run
      conn = Faraday.new(
        url: 'https://chicagoartisanmarket.com',
        headers: { 
          'Content-Type' => 'application/json',
          'User-Agent' => 'GoScrape' # Agent can be whatever
        }
      ) do |f|
        f.request :gzip # Enable gzip compression for requests
      end

      # GET
      res = conn.get('/vendors/')
      doc = Nokogiri::HTML(res.body)
      doc.css('.elementor-widget-container h5').each do |h5|
      # Your extraction logic here
      full_text = h5.text.strip
      date = full_text[/^[^–]+/]&.strip
      date = date.sub(/\w+/) { |month| month.capitalize }

      event_name = h5.at_css('a')&.text&.strip
      event_link = h5.at_css('a')&.[]('href')

      parts = full_text.split('–').map(&:strip)
      address = parts[2] if parts.length > 2

        next if event_name.blank? || date.blank? || event_link.blank?

        event = Event.create(
          name: event_name,
          started_at: date,
          application_link: event_link,
          address: address,
          host_id: 1
        )

        if event.persisted?
            puts "Date: #{date}"
            puts "Event: #{event_name}"
            puts "Link: #{event_link}"
            puts "Address: #{address}"
        else
          puts "Failed to create event: #{event.errors.full_messages.join(', ')}"
        end
      end
    end
  end
end
