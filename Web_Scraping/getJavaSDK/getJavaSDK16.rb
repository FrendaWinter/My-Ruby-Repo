require 'json'
require 'nokogiri'
require 'restclient'

def show_help
    puts <<~TEXT
        
		Just: ruby getJavaSDK16.rb

		--- That all of it, Have Fun!! ----

    TEXT
end

productString = 'Java Development Kit 16 for windows'
@home_page = "https://www.oracle.com"
@urls = Array.new

# Get the latest version
url = "#{@home_page}/java/technologies/javase/16all-relnotes.html"
htmlContent = Nokogiri::HTML(RestClient.get(url))
version = String.new
htmlContent.css('li').each { 
	|li|
	if li.inner_html.include? "JDK" 
		version = li.inner_html.split(' ')[1]
		break
	end
}
# Add link following version
url = "#{@home_page}/java/technologies/javase/#{version.gsub(/\./, '-')}-relnotes.html" # New url ro find date

if version.nil?
	puts "#{productString}: Cannot retrieve version"
	exit false
end

# Add suffix to all vesion have same format (4 fields: 16 -> 16.0.0.0)
(3 - version.count('.')).times { 
	version.insert(-1, '.0')
}
# Get release date
htmlContent = Nokogiri::HTML(RestClient.get(url))
date = htmlContent.text.match(/^\D+\s(?:\d{1}|\d{2}),\s\d{4}$/).to_s
if date.nil?
	puts "#{productString}: Cannot retrieve release date"
	exit false
end

@urls << { desc: productString, link: "#{@home_page}/java/technologies/javase/jdk16-archive-downloads.html" }

@outResult = {
	:'description' => productString,
	:'date' => date,
	:'version' => version,
	:'timestamp' => Time.now
}

if @urls.length > 0
	@outResult[:'downloadInfo'] = {:'downloadDetails' => @urls}
end

puts JSON.pretty_generate(@outResult)