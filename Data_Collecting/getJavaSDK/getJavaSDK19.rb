require 'json'
require 'nokogiri'
require 'restclient'

productString = 'Java Development Kit 19 for windows'
@home_page = "https://www.oracle.com"
@urls = Array.new

# Initialize
timestamp = Time.now
puts "\n#{productString}: Starting #{productString} Collection:"
puts "#{productString}: Timestamp: #{timestamp}"

# Get the latest version
url = "#{@home_page}/java/technologies/javase/19all-relnotes.html"
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

# Add suffix to all vesion have same format (4 fields: 19 -> 19.0.0.0)
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

@urls << { desc: productString + ' - Windows x64 Compressed Archive', link: "https://download.oracle.com/java/19/archive/jdk-#{version}_windows-x64_bin.zip" }
@urls << { desc: productString + ' - Windows x64 Installer', link: "https://download.oracle.com/java/19/archive/jdk-#{version}_windows-x64_bin.exe" }
@urls << { desc: productString + ' - Windows x64 MSI Installer', link: "https://download.oracle.com/java/19/archive/jdk-#{version}_windows-x64_bin.msi" }

outResult = {
	:'description' => productString,
	:'date' => date,
	:'version' => version
}

if @urls.length > 0
	outResult[:'downloadInfo'] = {:'minFileSize' => 180 * 1024 *1024, :'downloadDetails' => @urls}
end

puts "#{productString.capitalize}: Result: #{outResult}"
puts "#{productString.capitalize}: Result: Run complete"