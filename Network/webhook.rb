#!/usr/bin/env ruby

# Simple webhook server


require 'json'
require 'optparse'
require 'sinatra'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: webhook.rb [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

  opts.on("-p PORT", "--port", "Port to listen on.") do |port|
    unless port =~/\d+/
        raise ArgumentError, "Port number must be a number"
    end
    options[:port] = port
  end

  opts.on("-o", "--output", "Output file path") do |o|
    options[:output] = o
  end

  opts.on("-l", "--log", "Use the logger.") do |l|
    options[:log] = l
  end
end.parse!

#set :logging, options[:log] unless options[:log].empty? 
#set :quiet, options[:verbose] unless options[:verbose].empty?

class WebhookServer < Sinatra
    unless options[:port].nil?
        configure do
            set :port, options[:port]
        end
    end

    post '/webhook' do
        request.body.rewind
        payload = JSON.parse(request.body.read)

        # Process the payload data as needed
        puts JSON.pretty_generate(payload)

        # Respond with a success message
        status 200
        body 'Webhook received successfully'
    end
end

run WebhookServer

# unless options[:output].empty?
#     begin
#         File.write(options[:output], JSON.pretty_generate(@Result))
#     rescue Errno::ENOENT => e
#         puts "Error: #{e.message}"
#     end
# end