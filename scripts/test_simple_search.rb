#!/usr/bin/env ruby
require_relative '../config/environment'

puts "Testing SimpleAlgoliaSearchService..."
puts "="*50

service = SimpleAlgoliaSearchService.new
result = service.ask("Find events in Texas")

puts "\n"
puts result
puts "\n"
puts "="*50
