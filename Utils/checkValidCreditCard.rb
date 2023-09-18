#!/usr/bin/env ruby
# frozen_string_literal: true

# CLI App for check valid credit card

require 'creditcard'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: checkValidCreditCard.rb [options]'

  opts.on('-c', '--check CARD', 'Check credit card') do |card|
    options[:card] = card
  end
end.parse!

remain_option = ARGV.pop
if remain_option
  puts
  puts "Invalid option [#{remain_option}], please using '-c CARD' or '--check CARD'"
  puts
  exit false
end
begin
  puts
  puts "Credit card number: #{options[:card]}"
  if !options[:card].empty? && options[:card].creditcard?
    puts '=> Valid: True'
    puts "=> Type: #{options[:card].creditcard_type}"
  else
    puts '=> Valid: False'
  end
  puts
rescue StandardError => e
  puts
  puts "Error: #{e.message}"
  puts
end
