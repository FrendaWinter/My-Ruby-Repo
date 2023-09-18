#!/usr/bin/env ruby
# frozen_string_literal: true

# CLI app for currency conversion

require 'money'
require 'eu_central_bank'

eu_bank = EuCentralBank.new
eu_bank.update_rates

Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN
# call this before calculating exchange rates
# this will download the rates from ECB
Money.default_bank = eu_bank

def show_help
  puts
  puts 'CLI app for currency conversion'
  puts
  puts '--help          Show help message'
  puts
  puts 'Example:'
  puts '    Normal usage: ruby currencyConverter.rb --amount 1000 --from USD --to EUR  ~  10.00 USD -> EUR'
  puts
end

@amount = String.new
@from = String.new
@to = String.new

show_help if ARGV.empty?
while (arg = ARGV.shift)
  case arg
  when '--help'
    begin
      show_help; exit false
    end
  when '--amount' then @amount = ARGV.shift.to_i
  when '--from' then @from = ARGV.shift.to_s
  when '--to' then @to = ARGV.shift.to_s
  else
    next
  end
end

puts Money.new(@amount, @from).exchange_to(@to).to_f
