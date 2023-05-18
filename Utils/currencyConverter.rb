#!/usr/bin/env ruby

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
    puts "CLI app for currency conversion"
    puts
    puts "--help          Show help message"
    puts
    puts "Example:"
    puts "    Normal usage: ruby currencyConverter.rb --amount 1000 --from USD --to EUR  ~  10.00 USD -> EUR"     
    puts
end

@amount, @from, @to = Object.new, Object.new, Object.new

show_help if ARGV.empty?
while arg = ARGV.shift do
    case arg
        when "--help" then 
          begin
            show_help; exit false
          end
        when "--amount" then @amount = ARGV.shift.to_i
        when "--from" then @from = ARGV.shift.to_s
        when "--to" then @to = ARGV.shift.to_s
    end
end

puts Money.new(@amount, @from).exchange_to(@to).to_f