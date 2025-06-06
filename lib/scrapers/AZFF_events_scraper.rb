require 'faraday'
require 'faraday/gzip'
require 'nokogiri'

# Hello!

module Scrapers
  class AZFFEventsScraper
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

      res = conn.get('/states/AZ')
      doc = Nokogiri::HTML(res.body)
      articles = doc.css('.event')

      articles.each do |article|
        title = article.at_css('h4')&.text&.strip
        date = article.at_css('.date')&.text&.strip
        location = article.at_css('.location')&.text&.strip
        link = article.at_css('a')
        link_href = link&.[]('href')
        
        event = Event.create(
          started_at: date,
          address: location,
          application_link: "https://www.fairsandfestivals.net/states/AZ" + link_href,
          host_id: 1,
          name: title
        )
        
        if event.persisted?
          puts "Event created: #{event.name} on #{event.started_at}"
        else
          puts "Failed to create event: #{event.name}, #{event.errors.full_messages.join(', ')}"
        end
      end
    end
  end
end
