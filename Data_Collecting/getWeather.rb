#!/usr/bin/env ruby
# frozen_string_literal: true

# This Ruby CLI app will returns the weather information of the input city name

require 'net/http'
require 'json'

def show_help
  puts
  puts 'This Ruby CLI app will returns the weather information of the input city name'
  puts
  puts '--help          Show help message'
  puts '-c, --city      City Name'
  puts "To make it more precise put the city's name, comma, 2-letter country code (ISO3166). You will get all proper cities in chosen country."
  puts "The order is important - the first is city name then comma then country. Example - 'London,GB' or 'New York,US'"
  puts
  puts 'Example:'
  puts "    Normal usage: ruby getWeather.rb --c 'London' --c 'Ho Chi Minh' --c 'New York'"
  puts "    With country code: ruby getWeather.rb --city 'London,GB'"
  puts
end

def get_weather(city)
  # API endpoint for OpenWeatherMap
  uri = URI('https://api.openweathermap.org/data/2.5/weather')

  # API key for OpenWeatherMap (you can get one for free by signing up on their website)
  api_key = '' # Your API key
  # Construct the API request URL with the city name name and API key

  uri.query = URI.encode_www_form({
                                    q: city,
                                    appid: api_key,
                                    units: 'imperial' # Use imperial units (e.g. Fahrenheit) instead of metric
                                  })

  # Send the API request and parse the response
  res = Net::HTTP.get_response(uri)
  data = JSON.parse(res.body)

  out_result = {}
  result = {}
  # Check if the API request was successful
  if data['cod'] == 200
    # Extract the weather information from the API response
    out_result[:temperature] = data['main']['temp']
    out_result[:description] = data['weather'][0]['description']
    out_result[:humidity] = data['main']['humidity']
    out_result[:wind_speed] = data['wind']['speed']

  else
    # Return error message if the API request failed
    out_result[:Error] = data['message']
  end
  result[:"#{city}"] = out_result
  result
end

@city = String.new

show_help if ARGV.empty?
while (arg = ARGV.shift)
  case arg
  when '--help' then show_help
                     exit
  when '-c', '--city'
    begin
      @city = ARGV.shift.to_s
      puts JSON.pretty_generate(get_weather(@city))
    end
  else
    begin
      puts 'Invalid argument'
      exit false
    end
  end
end
