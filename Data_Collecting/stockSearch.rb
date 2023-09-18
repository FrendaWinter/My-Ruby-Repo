#!/usr/bin/env ruby
# frozen_string_literal: true

# CLI app that searches for stock info.

require 'net/http'
require 'json'

def get_stock(stock)
  api_key = 'YOUR_API_KEY'
  response = Net::HTTP.get(URI("https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=#{stock}&apikey=#{api_key}"))
  data = JSON.parse(response)

  detail_result = {}
  out_result = {}
  detail_result[:price] = data['Global Quote']['05. price']
  detail_result[:open] = data['Global Quote']['02. open']
  detail_result[:high] = data['Global Quote']['03. high']
  detail_result[:low] = data['Global Quote']['04. low']
  detail_result[:'latest trading day'] = data['Global Quote']['07. latest trading day']
  detail_result[:'change percent'] = data['Global Quote']['10. change percent']
  out_result[:"#{stock}"] = detail_result
  out_result
end

def show_help
  puts
  puts 'This Ruby CLI app searches for stock info'
  puts
  puts '--help          Show help message'
  puts
  puts 'Example:'
  puts '    Normal usage: ruby stockSearch.rb AAPL'
  puts
end

@stocks = []

show_help if ARGV.empty?
while (arg = ARGV.shift)
  case arg
  when '--help' then show_help
                     exit false
  else @stocks << arg.to_s
  end
end

@stocks.each do |stock|
  puts JSON.pretty_generate(get_stock(stock))
end
