#!/usr/bin/env ruby

# CLI app will search for price of given crypto

require 'net/http'
require 'json'


def search_crypto_price(crypto_symbol)
  url = "https://api.coingecko.com/api/v3/simple/price?ids=#{crypto_symbol}&vs_currencies=usd"

  response = HTTParty.get(url)

  if response.code == 200
    data = JSON.parse(response.body)
    price = data[crypto_symbol.downcase]['usd']
    puts "The current price of #{crypto_symbol} is $#{price}"
  else
    puts "Error: #{response.code}"
  end
end

# Example usage:
search_crypto_price('BTC') # Replace 'BTC' with the symbol of the cryptocurrency you want to search for
