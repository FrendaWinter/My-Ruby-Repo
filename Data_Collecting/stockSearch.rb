#!/usr/bin/env ruby

# Still in development

# CLI app that searches for stock info.

require 'net/http'
require 'json'

def getStock(stock)
  api_key = 'MNJOAE390KQ6KPSU'
  url = "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=#{stock}&apikey=#{api_key}"
  uri = URI(url)
  response = Net::HTTP.get(uri)
  data = JSON.parse(response)
  return data['Global Quote']['05. price']
end

def show_help
    puts
    puts "This Ruby CLI app searches for stock info"
    puts
    puts "--help          Show help message"
    puts
    puts "Example:"
    puts "    Normal usage: ruby stockSearch.rb APPL"
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
            puts getStock(arg)
          end
    end
end
