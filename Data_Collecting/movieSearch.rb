#!/usr/bin/env ruby

# Still in development

# CLI app that searches stock info.

require 'net/http'
require 'json'

def get_forest_gump_info()
  api_key = 'Your_API_key'
  title = 'Forrest Gump'
  url = "http://www.omdbapi.com/?apikey=#{api_key}&t=#{title}"
  uri = URI(url)
  response = Net::HTTP.get(uri)
  data = JSON.parse(response)
  return data
end

puts JSON.pretty_generate(get_forest_gump_info)