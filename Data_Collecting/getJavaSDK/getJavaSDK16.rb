require 'json'
require 'nokogiri'
require 'restclient'

def show_help
    puts <<~TEXT
        
		Just: ruby getJavaSDK16.rb

		--- That all of it, Have Fun!! ----

    TEXT
end

@home_page = "https://www.oracle.com"
@productString = 'Java Development Kit 16 for windows'
def getJavaSDKVersion
	urls = Array.new
	# Get the latest version
	version = String.new
	htmlContent = Nokogiri::HTML(RestClient.get("#{@home_page}/java/technologies/javase/16all-relnotes.html"))
	htmlContent.css('li').each { 
		|li|
		if li.inner_html.include? "JDK"
			version = li.inner_html.split(' ')[1]
			break
		end
	}
	if version.empty? then puts "#{@productString}: Cannot retrieve version"; exit false end

	# Add link following version
	htmlContent = Nokogiri::HTML(RestClient.get("#{@home_page}/java/technologies/javase/#{version.gsub(/\./, '-')}-relnotes.html"))

	# Add suffix to all vesion have same format (4 fields: 16 -> 16.0.0.0)
	(3 - version.count('.')).times { version.insert(-1, '.0') }

	# Get release date
	date = htmlContent.text.match(/^\D+\s(?:\d{1}|\d{2}),\s\d{4}$/).to_s
	if date.empty? then puts "#{@productString}: Cannot retrieve release date"; exit false end

	urls << { desc: @productString, link: "#{@home_page}/java/technologies/javase/jdk16-archive-downloads.html" }
	outResult = {
		:'description' => @productString,
		:'date' => date,
		:'version' => version,
		:'timestamp' => Time.now
	}
	outResult[:'downloadInfo'] = {:'downloadDetails' => urls} if urls.length > 0
	return outResult
end

while arg = ARGV.shift do
    case arg
        when "--help" then show_help
        else puts JSON.pretty_generate(getJavaSDKVersion)
    end
end