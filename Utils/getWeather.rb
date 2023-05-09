#!/usr/bin/env ruby

# This Ruby CLI app will returns the weather information of the input city name

require 'net/http'
require 'json'

# API endpoint for OpenWeatherMap
uri = URI('https://api.openweathermap.org/data/2.5/weather')

# Links: https://openweathermap.org/current#name
# API key for OpenWeatherMap (you can get one for free by signing up on their website)
api_key = '00000000000000000000000000000' # Your API key

# Get the name of the city name from the user
print 'Enter the name of the city name: '
cityName = gets.chomp.downcase

# Construct the API request URL with the city name name and API key
uri.query = URI.encode_www_form({
  q: cityName,
  appid: api_key,
  units: 'imperial' # Use imperial units (e.g. Fahrenheit) instead of metric
})

# Send the API request and parse the response
res = Net::HTTP.get_response(uri)
data = JSON.parse(res.body)

# Check if the API request was successful
if data['cod'] == 200
  # Extract the weather information from the API response
  temperature = data['main']['temp']
  description = data['weather'][0]['description']
  humidity = data['main']['humidity']
  wind_speed = data['wind']['speed']
  
  # Print the weather information to the console
  puts "Current weather in #{cityName.capitalize}:"
  puts "Temperature: #{temperature}°F"
  puts "Description: #{description}"
  puts "Humidity: #{humidity}%"
  puts "Wind Speed: #{wind_speed} mph"
else
  # Print an error message if the API request failed
  puts "Error: #{data['message']}"
end