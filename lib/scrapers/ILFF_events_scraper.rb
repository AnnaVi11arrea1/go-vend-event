require 'faraday'
require 'faraday/gzip'
require 'nokogiri'

# Hello!

module Scrapers
  class ILFFEventsScraper
    def self.run
      conn = Faraday.new(
        url: 'https://www.fairsandfestivals.net',
        headers: { 
          'Content-Type' => 'application/json',
          'User-Agent' => 'GoScrape' # Agent can be whatever
        }
      ) do |f|
        f.request :gzip # Enable gzip compression for requests
      end

      # GET
      res = conn.get('/states/IL')
      doc = Nokogiri::HTML(res.body)
      articles = doc.css('.event')

      articles.each do |article|
        title = article.at_css('h4')&.text&.strip.squish
        date = article.at_css('.date')&.text&.strip
        location = article.at_css('.location')&.text&.strip
        link = article.at_css('a')
        link_href = link&.[]('href')

                # Skip if event with the same name already exists
        if Event.exists?(name: title, host_id: 1)
          puts "Skipping duplicate event: #{title}"
          next
        end
        
        event = Event.find_or_create_by(
          name: title,
          host_id: 1
          ) do |e|
          e.started_at = date,
          e.tags = 'Illinois, Fairs and Festivals',
          e.address = location,
          e.application_link = link_href
        end
        if event.persisted?
          puts "Event created: #{event.name} on #{event.started_at}"
        else
          puts "Failed to create event: #{event.name}, #{event.errors.full_messages.join(', ')}"
        end
      end
    end
  end
end
