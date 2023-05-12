#!/usr/bin/env ruby

# Still in development

# CLI app that searches stock info.

require 'net/http'
require 'json'

def get_apple_stock_price()
  api_key = 'MNJOAE390KQ6KPSU'
  url = "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=EMPTYNULL&apikey=#{api_key}"
  uri = URI(url)
  response = Net::HTTP.get(uri)
  data = JSON.parse(response)
  return data['Global Quote']['05. price']
end

puts get_apple_stock_price
