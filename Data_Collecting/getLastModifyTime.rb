require 'net/http'
require 'uri'

def show_help
    puts <<~TEXT
        CLI that return the last modification time of that website, if can't get the time, return 0.

		Usage: ruby getLastModifyTime.rb https://www.youtube.com/?gl=VN 

        => Fri, 02 Jun 2023 03:52:54 GMT

		--- That all of it, Have Fun!! ----

    TEXT
end

def	getLastModifiedTimeHttp(url)
    begin
        _uri=URI.parse(url)
        _http = Net::HTTP.new(_uri.host, _uri.port)
        # Toggle SSL when needed
        if _uri.scheme == "https"
            _http.use_ssl = true
            _http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        # Start Http request
        _http.start {
            _resp1 = _http.request_head(_uri.request_uri)
            _lastModifiedTime =_resp1.header['Last-Modified']
            if _lastModifiedTime == nil
                _lastModifiedTime = _resp1.header['Date']
            end
            return _lastModifiedTime
        }
    rescue => err
        return 0
    end
end

@urls = Array.new

show_help if ARGV.empty?
while arg = ARGV.shift do
    case arg
        when "--help" then show_help; exit
        else @urls << arg
    end
end

@urls.each do |url|
    puts getLastModifiedTimeHttp(url)   
end
