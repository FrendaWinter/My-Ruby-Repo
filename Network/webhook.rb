#!/usr/bin/env ruby

# Simple webhook server

require 'json'
require 'sinatra'

def show_help
    puts
    puts 'Simple webhook server'
    puts
    puts '--help          Show help message"'
    puts '-p PORT         Set the port (default is 4567)'
    puts
    puts 'And run with: ruby webhook.rb -p 4567'
    puts 'Webhook server will start at http://localhost:4567/webhook'
    puts
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

while arg = ARGV.shift do
    case arg
        when "--help" then show_help; exit false
    end
end