require 'json'
require 'nokogiri'
require 'restclient'

def show_help
    puts <<~TEXT
        
		Just: ruby getJavaSDK.rb 16 (Supported Java 11~20)

		--- That all of it, Have Fun!! ----

    TEXT
end

@home_page = 'https://www.oracle.com'
def getJavaSDKfullVersion(majorVersion)
	begin
	productString = "Java Development Kit #{majorVersion} for windows"

	urls, fullVersion = Array.new, String.new
	# Get the latest version
	htmlContent = Nokogiri::HTML(RestClient.get("#{@home_page}/java/technologies/javase/#{majorVersion}all-relnotes.html"))
	htmlContent.css('li').each { 
		|li|
		if li.inner_html.include? "JDK"
			fullVersion = li.inner_html.split(' ')[1]
			break
		end
	}
	if fullVersion.empty? then puts "#{productString}: Cannot retrieve fullVersion"; exit false end

	# Add link following fullVersion
	htmlContent = Nokogiri::HTML(RestClient.get("#{@home_page}/java/technologies/javase/#{fullVersion.gsub(/\./, '-')}-relnotes.html"))

	if majorVersion.to_i <= 16 then
		urls << { desc: productString, link: "#{@home_page}/java/technologies/javase/jdk#{majorVersion}-archive-downloads.html" }
	else
		urls << { desc: productString + ' - Windows x64 Compressed Archive', link: "https://download.oracle.com/java/#{majorVersion}/archive/jdk-#{fullVersion}_windows-x64_bin.zip" }
		urls << { desc: productString + ' - Windows x64 Installer', link: "https://download.oracle.com/java/#{majorVersion}/archive/jdk-#{fullVersion}_windows-x64_bin.exe" }
		urls << { desc: productString + ' - Windows x64 MSI Installer', link: "https://download.oracle.com/java/#{majorVersion}/archive/jdk-#{fullVersion}_windows-x64_bin.msi" }
	end

	# Add suffix to all vesion have same format (4 fields: #{majorVersion} -> #{majorVersion}.0.0.0)
	(3 - fullVersion.count('.')).times { fullVersion.insert(-1, '.0') }

	# Get release date
	date = htmlContent.text.match(/^\D+\s(?:\d{1}|\d{2}),\s\d{4}/).to_s
	if date.empty? then puts "#{productString}: Cannot retrieve release date"; exit false end

	outResult = {
		:'description' => productString,
		:'latestVersion' => fullVersion,
		:'date' => date,
		:'timestamp' => Time.now
	}
	outResult[:'downloadInfo'] = {:'downloadDetails' => urls} if urls.length > 0
	return outResult
	rescue StandardError => e
		puts "Error: #{e.message}"
		exit false
	end
end

if ARGV.empty? then show_help 
else
	while arg = ARGV.shift do
		case arg
			when "--help" then show_help
			else puts JSON.pretty_generate(getJavaSDKfullVersion(arg))
		end
	end
end