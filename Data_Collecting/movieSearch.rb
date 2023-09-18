#!/usr/bin/env ruby
# frozen_string_literal: true

# CLI app that searched movies and returns info

require 'net/http'
require 'json'

def getMovie(movie)
  api_key = 'Your_API_key'
  url = "http://www.omdbapi.com/?apikey=#{api_key}&t=#{movie}"
  uri = URI(url)
  response = Net::HTTP.get(uri)
  JSON.parse(response)
end

def show_help
  puts
  puts 'This Ruby CLI app that searched movies and returns info'
  puts
  puts '--help          Show help message'
  puts
  puts 'Example:'
  puts "    Normal usage: ruby movieSearch.rb 'Forrest Gump'"
  puts
end

show_help if ARGV.empty?
while (arg = ARGV.shift)
  case arg
  when '--help'
    begin
      show_help; exit false
    end
  else

    puts getMovie(arg)

  end
end
