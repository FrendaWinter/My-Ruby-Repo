#!/usr/bin/env ruby
# frozen_string_literal: true

# This Ruby CLI app will returns latest version and releases date when input github link of that application

require 'json'
require 'nokogiri'
require 'restclient'

@urls = []
@output_path = String.new

def show_help
  puts
  puts 'Returns latest version and releases date when input github link of that application'
  puts
  puts '--help          Show help message'
  puts '-o,--output     Path to output file, if file not exist then create new file'
  puts
  puts 'Example:'
  puts '    Normal usage: getLatestVersionOfAppOnGitHub.rb https://github.com/keepassxreboot/keepassxc'
  puts '    Get output into file at current folder: getLatestVersionOfAppOnGitHub.rb https://github.com/keepassxreboot/keepassxc -o ./output.json'
  puts '    Multiple link: getLatestVersionOfAppOnGitHub.rb https://github.com/keepassxreboot/keepassxc https://github.com/atom/atom -o /home/test/output.json'
  puts
end

show_help if ARGV.empty?
while (arg = ARGV.shift)
  case arg
  when '--help' then show_help
                     exit
  when '-o', '--output' then @output_path = ARGV.shift.to_s
  else @urls << arg
  end
end

def findVersionAndDate(url)
  version = String.new
  date = String.new
  out_result = { 'products': url.split('/').last.capitalize }
  # Get the latest version and date from the web
  html_content = Nokogiri::HTML(RestClient.get(url))
  html_content.css('a.Link--primary').each do |a|
    if a.inner_html =~ /Latest/
      version = a['href'].match(/(\d+\.\d+\.\d+|\d+\.\d+|\d+\.\d+\.\d+\.\d+)/).to_s
      date = a.inner_html.match(/\D{3}\s(?:\d{1}|\d{2}),\s\d{4}/).to_s
    end
  end
  if version.empty? || date.empty?
    # Return error if can't find version or date
    out_result[:error] = "Can't find version or date of this product"
  else
    out_result[:version] = version
    out_result[:date] = date
  end
  out_result
rescue StandardError => e
  out_result[:error] = e.message
  out_result
end

@result = []

@urls.each do |url|
  @result << findVersionAndDate(url)
end

if @output_path.empty?
  puts JSON.pretty_generate(@result)
else
  begin
    File.write(@output_path, JSON.pretty_generate(@result))
  rescue Errno::ENOENT => e
    puts "Error: #{e.message}"
  end
end
