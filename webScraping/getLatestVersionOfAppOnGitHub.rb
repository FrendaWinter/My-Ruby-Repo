#!/usr/bin/env ruby
# This Ruby CLI app will returns latest version and releases date when input github link of that application

require 'json'
require 'nokogiri'
require 'restclient'

@urls = Array.new
@outputPath = String.new

def show_help
    puts
    puts "Returns latest version and releases date when input github link of that application"
    puts
    puts "--help          Show help message"
    puts "-o,--output     Path to output file, if file not exist then create new file"
    puts
    puts "Example:"
    puts "    Normal usage: getLatestVersionOfAppOnGitHub.rb https://github.com/keepassxreboot/keepassxc"
    puts "    Get output into file at current folder: getLatestVersionOfAppOnGitHub.rb https://github.com/keepassxreboot/keepassxc -o ./output.json"
    puts "    Multiple link: getLatestVersionOfAppOnGitHub.rb https://github.com/keepassxreboot/keepassxc https://github.com/atom/atom -o /home/test/output.json" 
end

show_help if ARGV.empty?
while arg = ARGV.shift do
    case arg
        when "--help" then show_help; exit
        when "-o" || "output" then @outputPath = ARGV.shift.to_s
        else @urls << arg
    end
end

def findVersionAndDate(url)
    version, date = String.new, String.new
    outResult = { :'products' => url.split('/').last.capitalize }
    # Get the latest version and date from the web
    htmlContent = Nokogiri::HTML(RestClient.get(url))
    htmlContent.css('a.Link--primary').each {
        |a|
        if a.inner_html =~ /Latest/
            version = a['href'].match(/(\d+\.\d+\.\d+|\d+\.\d+|\d+\.\d+\.\d+\.\d+)/).to_s
            date = a.inner_html.match(/\D{3}\s(?:\d{1}|\d{2}),\s\d{4}/).to_s
        end
    }
    if version.empty? || date.empty?
        # Return error if can't find version or date
        outResult[:'error'] = "Can't find version or date of this product"
        return outResult
    else
        outResult[:'version'] = version
        outResult[:'date'] = date
        return outResult
    end
end

@Result = Array.new

@urls.each {
    |url|
    @Result << findVersionAndDate(url)
}

if @outputPath.nil?
    puts JSON.pretty_generate(@Result)
else
    begin
        File.write(@outputPath, @Result)
    rescue Errno::ENOENT => e
        puts "Error: #{e.message}"
    end
end