#!/usr/bin/env ruby

# CLI App for check valid credit card

require 'creditcard'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: checkValidCreditCard.rb [options]"

  opts.on("-c", "--check CARD", "Check credit card") do |card|
    options[:card] = card
  end
end.parse!

remainOption = ARGV.pop
if remainOption
    puts
    puts "Invalid option [#{remainOption}], please using '-c CARD' or '--check CARD'"
    puts
    exit false
end
begin
    if !options[:card].empty? && options[:card].creditcard?
        puts
        puts "Credit card number: #{options[:card]}"
        puts "=> Valid: True"
        puts "=> Type: #{options[:card].creditcard_type}"
        puts
    else
        puts
        puts "Credit card number: #{options[:card]}"
        puts "=> Valid: False"
        puts
    end
rescue => e
    puts
    puts "Error: #{e.message}"
    puts
end