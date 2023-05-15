#!/usr/bin/env ruby

# Still in development

# CLI app for currency conversion

require 'money'
require 'eu_central_bank'

eu_bank = EuCentralBank.new
eu_bank.update_rates

Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN
# call this before calculating exchange rates
# this will download the rates from ECB
Money.default_bank = eu_bank

puts Money.new(1000, 'USD').exchange_to('CAD').to_f

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

show_help if ARGV.empty?
while arg = ARGV.shift do
    case arg
        when "--help" then 
          begin
            show_help; exit false
          end
        else 
          begin 
            puts getStock(arg)
          end
    end
end
