require 'json'
require 'nokogiri'
require 'restclient'

urls = Array.new
while arg = ARGV.shift
    urls << arg
end

version, date = String.new, String.new

urls.each {
    |url|
    htmlContent = Nokogiri::HTML(RestClient.get(url))
    htmlContent.css('a.Link--primary').each {
        |a|
        if a.inner_html =~ /Latest/
            version = a['href'].match(/(\d+\.\d+\.\d+|\d+\.\d+|\d+\.\d+\.\d+\.\d+)/).to_s
            date = a.inner_html.match(/\D{3}\s(?:\d{1}|\d{2}),\s\d{4}/).to_s
        end
    }
}

if version.nil?
	puts "#{productString}: Cannot retrieve version"
	exit false
end
if date.nil?
	puts "#{productString}: Cannot retrieve release date"
	exit false
end


outResult = {
    :'version' => version,
    :'date' => date,
    #:'description' => productString
}

# @urls << { desc: productString + ' - Apple chip', link: "https://github.com/keepassxreboot/keepassxc/releases/download/#{version}/KeePassXC-#{version}-arm64.dmg" }
# @urls << { desc: productString + ' - Intel chip', link: "https://github.com/keepassxreboot/keepassxc/releases/download/#{version}/KeePassXC-#{version}-x86_64.dmg" }
 
# Add link following version

# if @urls.length > 0
# 	outTable[:'downloadInfo'] = {:'minFileSize' => 116 * 1024 * 1024, :'downloadDetails' => @urls}
# end
puts JSON.pretty_generate(outResult)