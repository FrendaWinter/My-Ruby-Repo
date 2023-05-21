#!/usr/bin/env ruby

# Still in development

# CLI app will search for price of given crypto

require 'net/http'
require 'openssl'
require 'date'
require 'json'
require 'optparse'

module CoinAPIv1
  class Client
    def initialize(api_key:, options: {})
      @api_key = api_key
      @options = default_options.merge(options)
    end

    def metadata_list_all_exchanges
      request(endpoint: 'exchanges')
    end

    def metadata_list_all_assets
      request(endpoint: 'assets').collect! do |asset|
        Transformers::asset(asset)
      end
    end

    def metadata_list_all_symbols
      request(endpoint: 'symbols').each do |symbol|
        case symbol[:symbol_type]
        when 'FUTURES'
          symbol[:future_delivery_time] = Date.parse(symbol[:future_delivery_time])
        when 'OPTION'
          symbol[:option_expiration_time] = Date.parse(symbol[:option_expiration_time])
        end
        symbol
      end
    end

    def exchange_rates_get_specific_rate(asset_id_base:, asset_id_quote:, parameters: {})
      endpoint = "exchangerate/#{asset_id_base}/#{asset_id_quote}"
      exchange_rate = request(endpoint: endpoint, parameters: parameters)
      exchange_rate[:time] = DateTime.parse(exchange_rate[:time])
      exchange_rate
    end

    def exchange_rates_get_all_current_rates(asset_id_base:)
      all_rates = request(endpoint: "exchangerate/#{asset_id_base}")
      all_rates[:rates].collect! do |rate|
        rate[:time] = DateTime.parse(rate[:time])
        rate
      end
    end

    def ohlcv_list_all_periods
      request(endpoint: "ohlcv/periods")
    end

    def ohlcv_latest_data(symbol_id:, period_id:, parameters: {})
      endpoint = "ohlcv/#{symbol_id}/latest"
      params = parameters.merge(period_id: period_id)
      request(endpoint: endpoint, parameters: params).collect! do |data_point|
        Transformers::data_point(data_point)
      end
    end

    def ohlcv_historical_data(symbol_id:, period_id:, time_start:, parameters: {})
      endpoint = "ohlcv/#{symbol_id}/history"
      params = parameters.merge({period_id: period_id, time_start: time_start})
      request(endpoint: endpoint, parameters: params).collect! do |data_point|
        Transformers::data_point(data_point)
      end
    end

    def trades_latest_data_all(parameters: {})
      endpoint = "trades/latest"
      request(endpoint: endpoint, parameters: parameters).collect! do |trade|
        Transformers::trade(trade)
      end
    end

    def trades_latest_data_symbol(symbol_id:, parameters: {})
      endpoint = "trades/#{symbol_id}/latest"
      request(endpoint: endpoint, parameters: parameters).collect! do |trade|
        Transformers::trade(trade)
      end
    end

    def trades_historical_data(symbol_id:, time_start:, parameters: {})
      endpoint = "trades/#{symbol_id}/history"
      params = parameters.merge(time_start: time_start)
      request(endpoint: endpoint, parameters: params).collect! do |trade|
        Transformers::trade(trade)
      end
    end

    def quotes_current_data_all
      endpoint = "quotes/current"
      request(endpoint: endpoint).collect! do |quote|
        Transformers::quote(quote)
      end
    end

    def quotes_current_data_symbol(symbol_id:)
      endpoint = "quotes/#{symbol_id}/current"
      Transformers::quote(request(endpoint: endpoint))
    end

    def quotes_latest_data_all(parameters: {})
      endpoint = "quotes/latest"
      request(endpoint: endpoint, parameters: parameters).collect! do |quote|
        Transformers::quote(quote)
      end
    end

    def quotes_latest_data_symbol(symbol_id:, parameters: {})
      endpoint = "quotes/#{symbol_id}/latest"
      request(endpoint: endpoint, parameters: parameters).collect! do |quote|
        Transformers::quote(quote)
      end
    end

    def quotes_historical_data(symbol_id:, time_start:, parameters: {})
      endpoint = "quotes/#{symbol_id}/history"
      params = parameters.merge(time_start: time_start)
      request(endpoint: endpoint, parameters: params).collect! do |quote|
        Transformers::quote(quote)
      end
    end

    def orderbooks_current_data_all
      endpoint = "orderbooks/current"
      request(endpoint: endpoint).collect! do |entry|
        Transformers::orderbook_entry(entry)
      end
    end

    def orderbooks_current_data_symbol(symbol_id:)
      endpoint = "orderbooks/#{symbol_id}/current"
      Transformers::orderbook_entry(request(endpoint: endpoint))
    end

    def orderbooks_latest_data(symbol_id:, parameters: {})
      endpoint = "orderbooks/#{symbol_id}/latest"
      request(endpoint: endpoint, parameters: parameters).collect! do |entry|
        Transformers::orderbook_entry(entry)
      end
    end

    def orderbooks_historical_data(symbol_id:, time_start:, parameters: {})
      endpoint = "orderbooks/#{symbol_id}/history"
      params = parameters.merge(time_start: time_start)
      request(endpoint: endpoint, parameters: params).collect! do |entry|
        Transformers::orderbook_entry(entry)
      end
    end

    private
    def default_headers
      headers = {}
      headers['X-CoinAPI-Key'] = @api_key
      headers['Accept'] = 'application/json'
      headers['Accept-Encoding'] = 'deflate, gzip'
      headers
    end

    def default_options
      options = {}
      options[:production] = true
      options
    end

    def headers
      default_headers.merge(@options.fetch(:headers, {}))
    end

    def base_url
      if @options[:production]
        'https://rest.coinapi.io/v1/'
      else
        'https://rest-test.coinapi.io/v1/'
      end
    end

    def response_compressed?
      headers['Accept-Encoding:'] == 'deflate, gzip'
    end

    def request(endpoint:, parameters: {})
      uri = URI.join(base_url, endpoint)
      uri.query = URI.encode_www_form(parameters)
      request = Net::HTTP::Get.new(uri)
      request.initialize_http_header(headers)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
	  # uncomment only in development enviroment if ruby don't have trusted CA directory
	  #http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      response = http.request(request)
      JSON.parse(response.body, symbolize_names: true)
    end
  end

  private
  module Transformers
    class << self
      def asset(a)
        if a[:type_is_crypto] != 0
          a[:type_is_crypto] = true
        else
          a[:type_is_crypto] = false
        end
        a
      end

      def data_point(dp)
        dp[:time_period_start] = DateTime.parse(dp[:time_period_start])
        dp[:time_period_end] = DateTime.parse(dp[:time_period_end])
        dp[:time_open] = DateTime.parse(dp[:time_open])
        dp[:time_close] = DateTime.parse(dp[:time_close])
        dp
      end

      def trade(t)
        t[:time_exchange] = DateTime.parse(t[:time_exchange])
        t[:time_coinapi] = DateTime.parse(t[:time_coinapi])
        t
      end

      def quote(q)
        q[:time_exchange] = DateTime.parse(q[:time_exchange])
        q[:time_coinapi] = DateTime.parse(q[:time_coinapi])

        if q.has_key?(:last_trade) and q[:last_trade]
          trade = q[:last_trade]
          trade[:time_exchange] = DateTime.parse(trade[:time_exchange])
          trade[:time_coinapi] = DateTime.parse(trade[:time_coinapi])
          q[:last_trade] = trade
        end
        q
      end

      def orderbook_entry(oe)
        oe[:time_exchange] = DateTime.parse(oe[:time_exchange])
        oe[:time_coinapi] = DateTime.parse(oe[:time_coinapi])
        oe
      end
    end
  end
end

test_key = '8DBDD7AE-5A8C-4D15-B854-C8A59AF75300'

api = CoinAPIv1::Client.new(api_key: test_key)

$result = {}

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: cryptoSearch.rb [options]"

    opts.on("-o FILEPATH", "--output", "Run verbosely") do |filePath|
        options[:filePath] = filePath
    end

    opts.on("-h", "--help", "Prints help") do
        puts opts
        exit
    end
end.parse!

exchange_rate = api.exchange_rates_get_specific_rate(asset_id_base: 'BTC',
                                                     asset_id_quote: 'USD')
$result[:"BTC to USD"] = exchange_rate

if options[:filePath]
    begin
        File.write(options[:filePath], JSON.pretty_generate($result))
    rescue Errno::ENOENT => e
        puts "Error: #{e.message}"
    end
else 
    puts JSON.pretty_generate($result)
end

# exchanges = api.metadata_list_all_exchanges()
# puts 'Exchanges'
# for exchange in exchanges
#   puts "Exchange ID: #{exchange[:exchange_id]}"
#   puts "Exchange website: #{exchange[:website]}"
#   puts "Exchange name: #{exchange[:name]}"
# end

# assets = api.metadata_list_all_assets

# puts('Assets')
# for asset in assets
#   puts "Asset ID: #{asset[:asset_id]}"
#   puts "Asset name: #{asset[:name]}"
#   puts "Asset type (crypto?): #{asset[:type_is_crypto]}"
# end

symbols = api.metadata_list_all_symbols
puts 'Symbols'

for symbol in symbols
  puts "Symbol ID: #{symbol[:symbol_id]}"
  puts "Exchange ID: #{symbol[:exchange_id]}"
  puts "Symbol type: #{symbol[:symbol_type]}"
  puts "Asset ID base: #{symbol[:asset_id_base]}"
  puts "Asset ID quote: #{symbol[:asset_id_quote]}"

  if (symbol['symbol_type'] == 'FUTURES')
    puts "Future delivery time: #{symbol[:future_delivery_time]}"
  end
  if (symbol['symbol_type'] == 'OPTION')
    puts "Option type is call: #{symbol[:option_type_is_call]}"
    puts "Option strike price: #{symbol[:option_strike_price]}"
    puts "Option contract unit: #{symbol[:option_contract_unit]}"
    puts "Option exercise style: #{symbol[:option_exercise_style]}"
    puts "Option expiration time: #{symbol[:option_expiration_time]}"
  end
end

# last_week = DateTime.iso8601('2017-05-23').to_s
# exchange_rate_last_week = api.exchange_rates_get_specific_rate(asset_id_base: 'BTC',
#                                                                asset_id_quote: 'USD',
#                                                                parameters: {time: last_week})

# puts "Time: #{exchange_rate_last_week[:time]}"
# puts "Base: #{exchange_rate_last_week[:asset_id_base]}"
# puts "Quote: #{exchange_rate_last_week[:asset_id_quote]}"
# puts "Rate: #{exchange_rate_last_week[:rate]}"

# current_rates = api.exchange_rates_get_all_current_rates(asset_id_base: 'BTC')

# for rate in current_rates
#   puts "Time: #{rate[:time]}"
#   puts "Quote: #{rate[:asset_id_quote]}"
#   puts "Rate: #{rate[:rate]}"
# end

# periods = api.ohlcv_list_all_periods

# for period in periods
#   puts "ID: #{period[:period_id]}"
#   puts "Seconds: #{period[:length_seconds]}"
#   puts "Months: #{period[:length_months]}"
#   puts "Unit count: #{period[:unit_count]}"
#   puts "Unit name: #{period[:unit_name]}"
#   puts "Display name: #{period[:display_name]}"
# end

# ohlcv_latest = api.ohlcv_latest_data(symbol_id: 'BITSTAMP_SPOT_BTC_USD',
#                                      period_id: '1MIN')

# def print_data_point(data_point)
#   puts "Period start: #{data_point[:time_period_start]}"
#   puts "Period end: #{data_point[:time_period_end]}"
#   puts "Time open: #{data_point[:time_open]}"
#   puts "Time close: #{data_point[:time_close]}"
#   puts "Price open: #{data_point[:price_open]}"
#   puts "Price close: #{data_point[:price_close]}"
#   puts "Price low: #{data_point[:price_low]}"
#   puts "Price high: #{data_point[:price_high]}"
#   puts "Volume traded: #{data_point[:volume_traded]}"
#   puts "Trades count: #{data_point[:trades_count]}"
# end

# for data_point in ohlcv_latest
#   print_data_point(data_point)
# end

# start_of_2016 = DateTime.iso8601('2016-01-01').to_s
# ohlcv_historical = api.ohlcv_historical_data(symbol_id: 'BITSTAMP_SPOT_BTC_USD',
#                                              period_id: '1YRS',
#                                              time_start: start_of_2016)

# for data_point in ohlcv_historical
#   print_data_point(data_point)
# end

# latest_trades = api.trades_latest_data_all

# def print_trade(trade)
#   puts "Symbol ID: #{trade[:symbol_id]}"
#   puts "Time Exchange: #{trade[:time_exchange]}"
#   puts "Time CoinAPI: #{trade[:time_coinapi]}"
#   puts "UUID: #{trade[:uuid]}"
#   puts "Price: #{trade[:price]}"
#   puts "Size: #{trade[:bsize]}"
#   puts "Taker Side: #{trade[:taker_side]}"
# end

# for trade in latest_trades
#   print_trade(trade)
# end

# latest_trades_doge = api.trades_latest_data_symbol(symbol_id: 'BITTREX_SPOT_BTC_DOGE')

# for trade in latest_trades_doge
#   print_trade(trade)
# end

# historical_trades_btc = api.trades_historical_data(symbol_id: 'BITSTAMP_SPOT_BTC_USD',
#                                                    time_start: start_of_2016)

# for trade in historical_trades_btc
#   print_trade(trade)
# end

# current_quotes = api.quotes_current_data_all

# def print_quote(quote)
#   puts "Symbol ID: #{quote[:symbol_id]}"
#   puts "Time Exchange: #{quote[:time_exchange]}"
#   puts "Time CoinAPI: #{quote[:time_coinapi]}"
#   puts "Ask Price: #{quote[:ask_price]}"
#   puts "Ask Size: #{quote[:ask_size]}"
#   puts "Bid Price: #{quote[:bid_price]}"
#   puts "Bid Size: #{quote[:bid_size]}"
# end

# for quote in current_quotes
#   print_quote(quote)
#   if quote.has_key? :last_trade
#     puts 'Last Trade:'
#     print_trade(quote[:last_trade])
#   end
# end

# current_quote_btc_usd = api.quotes_current_data_symbol(symbol_id: 'BITSTAMP_SPOT_BTC_USD')

# print_quote(current_quote_btc_usd)

# if current_quote_btc_usd.has_key? :last_trade
#   print_trade(current_quote_btc_usd[:last_trade])
# end

# quotes_latest_data = api.quotes_latest_data_all

# for quote in quotes_latest_data
#   print_quote(quote)
# end

# quotes_latest_data_btc_usd = api.quotes_latest_data_symbol(symbol_id: 'BITSTAMP_SPOT_BTC_USD')

# for quote in quotes_latest_data_btc_usd
#   print_quote(quote)
# end

# quotes_historical_data_btc_usd = api.quotes_historical_data(symbol_id: 'BITSTAMP_SPOT_BTC_USD',
#                                                             time_start: start_of_2016)

# for quote in quotes_historical_data_btc_usd
#   print_quote(quote)
# end

# orderbooks_current_data = api.orderbooks_current_data_all

# def print_entry(entry)
#   puts "Symbol ID: #{entry[:symbol_id]}"
#   puts "Time Exchange: #{entry[:time_exchange]}"
#   puts "Time CoinAPI: #{entry[:time_coinapi]}"
#   puts 'Asks:'
#   for ask in entry[:asks]
#     puts "- Price: #{ask[:price]}"
#     puts "- Size: #{ask[:size]}"
#   end
#   puts 'Bids:'
#   for bid in entry[:bids]
#     puts "- Price: #{bid[:price]}"
#     puts "- Size: #{bid[:size]}"
#   end
# end

# for entry in orderbooks_current_data
#   print_entry(entry)
# end


# orderbooks_current_data_btc_usd = api.orderbooks_current_data_symbol(symbol_id: 'BITSTAMP_SPOT_BTC_USD')

# print_entry(orderbooks_current_data_btc_usd)

# orderbooks_latest_data_btc_usd = api.orderbooks_latest_data(symbol_id: 'BITSTAMP_SPOT_BTC_USD')

# for entry in orderbooks_latest_data_btc_usd
#   print_entry(entry)
# end

# orderbooks_historical_data_btc_usd = api.orderbooks_historical_data(symbol_id: 'BITSTAMP_SPOT_BTC_USD',
#                                                                     time_start: start_of_2016)

# for entry in orderbooks_historical_data_btc_usd
#   print_entry(entry)
# end
