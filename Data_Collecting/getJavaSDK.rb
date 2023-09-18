#!/usr/bin/env ruby
# frozen_string_literal: true

# This Ruby CLI app will returns latest version, releases date, download links of Java SDK

# Following JDK release notes: https://www.oracle.com/java/technologies/javase/jdk-relnotes-index.html

require 'json'
require 'nokogiri'
require 'restclient'

def show_help
  puts <<~TEXT
    #{'      '}
    Just: ruby getJavaSDK.rb 16 (Supported Java 11~20)

    --- That all of it, Have Fun!! ----

  TEXT
end

@home_page = 'https://www.oracle.com'
def get_java_sdk_full_version(major_version)
  product_string = "Java Development Kit #{major_version} for windows"

  urls = []
  full_version = String.new
  # Get the latest version
  html_content = Nokogiri::HTML(RestClient.get("#{@home_page}/java/technologies/javase/#{major_version}all-relnotes.html"))
  html_content.css('li').each do |li|
    if li.inner_html.include? 'JDK'
      full_version = li.inner_html.split(' ')[1]
      break
    end
  end
  if full_version.empty?
    puts "#{product_string}: Cannot retrieve fullVersion"
    exit false
  end

  # Add link following fullVersion
  html_content = Nokogiri::HTML(RestClient.get("#{@home_page}/java/technologies/javase/#{full_version.gsub(/\./,
																																																					                                                      '-')}-relnotes.html"))

  if major_version.to_i <= 16
    urls << { desc: product_string,
              link: "#{@home_page}/java/technologies/javase/jdk#{major_version}-archive-downloads.html" }
  else
    urls << { desc: "#{product_string} - Windows x64 Compressed Archive",
              link: "https://download.oracle.com/java/#{major_version}/archive/jdk-#{full_version}_windows-x64_bin.zip" }
    urls << { desc: "#{product_string} - Windows x64 Installer",
              link: "https://download.oracle.com/java/#{major_version}/archive/jdk-#{full_version}_windows-x64_bin.exe" }
    urls << { desc: "#{product_string} - Windows x64 MSI Installer",
              link: "https://download.oracle.com/java/#{major_version}/archive/jdk-#{full_version}_windows-x64_bin.msi" }
  end

  # Add suffix to all vesion have same format (4 fields: #{majorVersion} -> #{majorVersion}.0.0.0)
  (3 - full_version.count('.')).times { full_version.insert(-1, '.0') }

  # Get release date
  date = html_content.text.match(/^\D+\s(?:\d{1}|\d{2}),\s\d{4}/).to_s
  if date.empty? then puts "#{product_string}: Cannot retrieve release date"
                      exit false end

  our_result = {
    'description': product_string,
    'latestVersion': full_version,
    'date': date,
    'timestamp': Time.now
  }
  our_result[:downloadInfo] = { 'downloadDetails': urls } if urls.length.positive?
  our_result
rescue StandardError => e
  puts "Error: #{e.message}"
  exit false
end

if ARGV.empty?
  show_help
else
  while (arg = ARGV.shift)
    case arg
    when '--help' then show_help
    else puts JSON.pretty_generate(get_java_sdk_full_version(arg))
    end
  end
end
