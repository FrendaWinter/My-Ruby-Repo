#!/usr/bin/env ruby

# Still in development

# CLI app for currency conversion

require 'money'
require 'money/bank/google_currency'

def convert_currency(amount, from_currency, to_currency)
  Money.use_i18n = false
  bank = Money::Bank::GoogleCurrency.new
  bank.ttl_in_seconds = 86400 # 1 day cache
  Money.default_bank = bank
  return Money.new(amount * 100, from_currency).exchange_to(to_currency).to_f
end

puts(100, 'USD', 'VND')