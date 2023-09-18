# frozen_string_literal: true

require 'net/http'
require 'uri'

def show_help
  puts <<~TEXT
          CLI that return the last modification time of that website, if can't get the time, return 0.

    Usage: ruby getLastModifyTime.rb https://www.youtube.com/?gl=VN#{' '}

          => Fri, 02 Jun 2023 03:52:54 GMT

    --- That all of it, Have Fun!! ----

  TEXT
end

def	getLastModifiedTimeHttp(url)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  # Toggle SSL when needed
  if uri.scheme == 'https'
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
  # Start Http request
  http.start do
    resp1 = http.request_head(uri.request_uri)
    last_modified_time = resp1.header['Last-Modified']
    last_modified_time = resp1.header['Date'] if last_modified_time.nil?
    return last_modified_time
  end
rescue StandardError => e
    puts "#{e.message}"
end

@urls = []

show_help if ARGV.empty?
while (arg = ARGV.shift)
  case arg
  when '--help' then show_help
                     exit
  else @urls << arg
  end
end

@urls.each do |url|
  puts getLastModifiedTimeHttp(url)
end
