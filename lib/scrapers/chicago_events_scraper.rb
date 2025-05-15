require 'faraday'
require 'faraday/gzip'
require 'nokogiri'

# Hello!

module Scrapers
  class ChicagoEventsScraper
    def self.run
      conn = Faraday.new(
        url: 'https://chicagoevents.com',
        headers: { 
          'Content-Type' => 'application/json',
          'User-Agent' => 'GoScrape' # Agent can be whatever
        }
      ) do |f|
        f.request :gzip # Enable gzip compression for requests
      end

      # GET
      res = conn.get('/vendors-and-artists/')
      doc = Nokogiri::HTML(res.body)
      articles = doc.css('.tribe-events-pro-photo__event-details')

      articles.each do |article|
        date = article.at_css('.event-date')&.text&.strip
        title = article.at_css('h3')&.text&.strip
        link = article.at_css('a')
        link_href = link&.[]('href')

        next if title.blank? || date.blank? || link_href.blank?

        event = Event.create(
          name: title,
          started_at: date,
          application_link: link_href,
          host_id: 1
        )

        if event.persisted?
          puts "Event created: #{event.name} on #{event.started_at}"
        else
          puts "Failed to create event: #{event.errors.full_messages.join(', ')}"
        end
      end
    end
  end
end
