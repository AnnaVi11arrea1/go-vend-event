require 'faraday'
require 'faraday/gzip'
require 'nokogiri'

# Hello!

module Scrapers
  class HometownVendorScraper
    def self.run
      conn = Faraday.new(
        url: 'https://hometownvendormarket.com',
        headers: { 
          'Content-Type' => 'application/json',
          'User-Agent' => 'GoScrape' # Agent can be whatever
        }
      ) do |f|
        f.request :gzip # Enable gzip compression for requests
      end

      # GET
      res = conn.get('/illinois/')
      doc = Nokogiri::HTML(res.body)
      articles = doc.css('.et-last-child')

      articles.each do |article|
        date_text = article.at_css('p')&.text&.strip
        date_only = date_text&.split('|')&.first&.strip
        date = date_only&.sub(/\w+/) { |month| month.capitalize }
        title = article.at_css('h2')&.text&.strip
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
