#!/usr/bin/env ruby

# Still in development

# CLI app that searches stock info.

require 'json'
require 'uri'
require 'net/http'
require 'colorize'

# gem install yahoo-finance
require 'yahoo-finance'

# Define an array of stock codes
stock_codes = ['AAPL', 'GOOG', 'MSFT', 'AMZN']

# Loop through each stock code and fetch its data
stock_codes.each do |code|
  quote = YahooFinance::Client.new.get_quote(code)
  puts "#{code}: #{quote.regular_market_price}"
end