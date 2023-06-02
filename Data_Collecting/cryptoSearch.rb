#!/usr/bin/env ruby

# Still in development

# CLI app will search for price, covert or view infomation of given crypto

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

    def exchange_rates_get_all_current_rates(asset_id_base:, parameters: {})
      all_rates = request(endpoint: "exchangerate/#{asset_id_base}", parameters: parameters)
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

# Get your apikey at https://www.coinapi.io/
test_key = '*******************************' # YOUR API KEY

$api = CoinAPIv1::Client.new(api_key: test_key)
$result = {}

$options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: cryptoSearch.rb [options] [argument]"

    # Exchange session
    opts.on( "-e", "--exchange", "Option for turn on exchange mode ~ get rate of the coin you want. Default is false.") do |e|
        $options[:exchange] = e
    end

    opts.on("--base BASE", "-b", "Option for input the base for exchange rate") do |base|
        $options[:base] = base
    end

    opts.on("--quote QUOTE", "-q", "Option for input the quote for exchange rate") do |quote|
        $options[:quote] = quote
    end

    # Symbol session
    opts.on("--symbol SYMBOL_ID", "-s", "Option for turn on and input symbol ID ~ get trade info with SYMBOL_ID") do |symbolID|
        $options[:symbolID] = symbolID
    end

    opts.on("--period PERIOD", "-p", "Option for input the period of the trade, must have SYMBOL_ID input") do |period|
        $options[:period] = period
    end

    # Utils
    # For both exchange and sym --time-start
    opts.on("-t TIME", "--time", "Options for input the time where record start. Follow iso8601 format. Eg: 2017-05-23") do |time|
        $options[:time] = time
    end

    opts.on("-o FILEPATH", "--output", "Write result into output") do |filePath|
        $options[:filePath] = filePath
    end
    
    opts.on("-h", "--help", "Prints help") do
        puts opts
        puts
        puts <<~TEXT
        Exemple: 
          Get Bitcoin current price in USD:           ruby cryptoSearch.rb -e -b BTC -q USD
          Get Bitcoin price in USD on specific date:  ruby cryptoSearch.rb -e -b BTC -q USD -t '2016-01-01'
          Get all rate of Bitcoin price:              ruby cryptoSearch.rb -e -b BTC

          Get exchange rate BTC->USD with SYMBOL ID within period:
          - Get current exchange rate with period is 1 minute:        ruby cryptoSearch.rb -s BITSTAMP_SPOT_BTC_USD -p '1MIN'
          - Get all record from 2016 to now, with period is 1 year:   ruby cryptoSearch.rb -s BITSTAMP_SPOT_BTC_USD -p '1YRS' -t '2016-01-01'

          If you want me to adding anything, please contact me with email: manhduongx@gmail.com
          --- That all of it, Have Fun!! ---
        TEXT
        exit
    end
end.parse!

remainOption = ARGV.pop
if remainOption
    puts
    puts "Unkhown option [#{remainOption}], please using defined option, print help (--help) for more information"
    puts
    exit false
end

def exchangeExecutor
  begin
    if $options[:exchange] then
      if $options[:base].nil? then raise "Please enter base coin with option '-b' or '--base', like this '-b BTC'" end
      
      if $options[:quote].nil? then
        unless $options[:time].nil? then time = DateTime.iso8601($options[:time]).to_s end
        all_rates = $api.exchange_rates_get_all_current_rates(asset_id_base: $options[:base], parameters: {time: time})
        for rate in all_rates
          $result[:"#{$options[:base]} to #{rate[:asset_id_quote]}"] = rate
        end
      else
        unless $options[:time].nil? then time = DateTime.iso8601($options[:time]).to_s end
        exchange_rate = $api.exchange_rates_get_specific_rate(asset_id_base: $options[:base], asset_id_quote: $options[:quote], parameters: {time: time})
        $result[:"#{$options[:base]} to #{$options[:quote]}"] = exchange_rate
      end
    end
  rescue => e
    $result[:error] = e.message
    $result[:backTrace] = e.backtrace
  end
end

def symbolExecutor
  begin
    if $options[:symbolID] then
      $result[:result] = Array.new
      unless $options[:time].nil? then 
        time = DateTime.iso8601($options[:time]).to_s
        ohlcv_historical = $api.ohlcv_historical_data(symbol_id: $options[:symbolID], period_id: $options[:period], time_start: time)
        for data_point in ohlcv_historical
          $result[:result].push data_point
        end
      else
        ohlcv_latest = $api.ohlcv_latest_data(symbol_id: $options[:symbolID], period_id: $options[:period])
        for data_point in ohlcv_latest
          $result[:result].unshift data_point
        end
      end
    end
  rescue => e
    $result[:error] = e.message
    $result[:backTrace] = e.backtrace
  end
end

exchangeExecutor
symbolExecutor
# Write input into file
if $options[:filePath]
    begin
        File.write($options[:filePath], JSON.pretty_generate($result))
    rescue Errno::ENOENT => e
        puts "Error: #{e.message}"
    end
else
    unless $result.empty? then
      puts JSON.pretty_generate($result)
    end
end