#!/usr/bin/env ruby

# CLI app that searched movies and returns info

require 'net/http'
require 'json'

def getMovie(movie)
  api_key = 'Your_API_key'
  url = "http://www.omdbapi.com/?apikey=#{api_key}&t=#{movie}"
  uri = URI(url)
  response = Net::HTTP.get(uri)
  data = JSON.parse(response)
  return data
end

def show_help
    puts
    puts "This Ruby CLI app that searched movies and returns info"
    puts
    puts "--help          Show help message"
    puts
    puts "Example:"
    puts "    Normal usage: ruby movieSearch.rb 'Forrest Gump'"
    puts
end

show_help if ARGV.empty?
while arg = ARGV.shift do
    case arg
        when "--help" then 
          begin
            show_help; exit false
          end
        else 
          begin 
            puts getMovie(arg)
          end
    end
end