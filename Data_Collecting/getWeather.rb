#!/usr/bin/env ruby

# This Ruby CLI app will returns the weather information of the input city name

require 'net/http'
require 'json'

def show_help
    puts
    puts "This Ruby CLI app will returns the weather information of the input city name"
    puts
    puts "--help          Show help message"
    puts "-c, --city      City Name"
    puts "To make it more precise put the city's name, comma, 2-letter country code (ISO3166). You will get all proper cities in chosen country."
    puts "The order is important - the first is city name then comma then country. Example - 'London,GB' or 'New York,US'"
    puts
    puts "Example:"
    puts "    Normal usage: ruby getWeather.rb --c 'London' --c 'Ho Chi Minh' --c 'New York'"
    puts "    With country code: ruby getWeather.rb --city 'London,GB'"
    puts
end

def getWeather(city)
  # API endpoint for OpenWeatherMap
  uri = URI('https://api.openweathermap.org/data/2.5/weather')

  # API key for OpenWeatherMap (you can get one for free by signing up on their website)
  api_key = '0203b5dcb72b8a7d86c52e1a9bfe433b' # Your API key
  # Construct the API request URL with the city name name and API key

  uri.query = URI.encode_www_form({
    q: city,
    appid: api_key,
    units: 'imperial' # Use imperial units (e.g. Fahrenheit) instead of metric
  })

  # Send the API request and parse the response
  res = Net::HTTP.get_response(uri)
  data = JSON.parse(res.body)
  
  outResult, result = {}, {}
  # Check if the API request was successful
  if data['cod'] == 200
    # Extract the weather information from the API response
    outResult[:'temperature'] = data['main']['temp']
    outResult[:'description'] = data['weather'][0]['description']
    outResult[:'humidity'] = data['main']['humidity']
    outResult[:'wind_speed'] = data['wind']['speed']
    result[:"#{city}"] = outResult
    
    return result
  else
    # Return error message if the API request failed
    outResult[:'Error'] = data['message']
    result[:"#{city}"] = outResult
    return result
  end
end

@city = String.new

show_help if ARGV.empty?
while arg = ARGV.shift do
    case arg
        when "--help" then show_help; exit
        when "-c" || "--city" then 
          begin
            @city = ARGV.shift.to_s
            puts JSON.pretty_generate(getWeather(@city))
          end
        else 
          begin 
            puts "Invalid argument"
            exit false
          end
    end
end