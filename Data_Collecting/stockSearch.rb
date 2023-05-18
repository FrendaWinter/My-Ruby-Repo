#!/usr/bin/env ruby

# CLI app that searches for stock info.

require 'net/http'
require 'json'

def getStock(stock)
  api_key = 'YOUR_API_KEY'
  response = Net::HTTP.get(URI("https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=#{stock}&apikey=#{api_key}"))
  data = JSON.parse(response)

  detailResult, outResult = {}, {}
  detailResult[:'price'] = data['Global Quote']['05. price']
  detailResult[:'open'] = data['Global Quote']['02. open']
  detailResult[:'high'] = data['Global Quote']['03. high']
  detailResult[:'low'] = data['Global Quote']['04. low']
  detailResult[:'latest trading day'] = data['Global Quote']['07. latest trading day']
  detailResult[:'change percent'] = data['Global Quote']['10. change percent']
  outResult[:"#{stock}"] = detailResult
  return outResult
end

def show_help
    puts
    puts "This Ruby CLI app searches for stock info"
    puts
    puts "--help          Show help message"
    puts
    puts "Example:"
    puts "    Normal usage: ruby stockSearch.rb AAPL"
    puts
end

@stocks = Array.new

show_help if ARGV.empty?
while arg = ARGV.shift do
    case arg
        when "--help" then show_help; exit false
        else @stocks << arg.to_s
    end
end

@stocks.each do |stock|
  puts JSON.pretty_generate(getStock(stock))
end