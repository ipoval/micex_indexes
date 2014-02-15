#!/usr/bin/env ruby -w
# encoding: utf-8

# Help
# http://www.finam.ru/analysis/leaders/
#
# Start
# WHEN=current|last_day ruby ./$0.rb
#

require 'json'
require 'open-uri'
require_relative 'notifyme'

@url = {
  'yesterday' => 'http://www.finam.ru/service.asp?name=leaders&action=grid&market=1&pitch=1&sorting.name=price-pchange&sorting.dir=desc&count=-1',
  'today' => 'http://www.finam.ru/service.asp?name=leaders&action=grid&market=1&pitch=5&sorting.name=price-pchange&sorting.dir=desc&count=-1&price-pchange.min=null&price-pchange.max=null',
}.fetch ENV['WHEN']
@page = open(@url).read

def micex_run(ticker)
  # @page.encode! Encoding::UTF_8, invalid: :replace, replace: ''

  page = @page.match(/#{ticker[:profile_id]}.+?(?=<\/tr)/).to_s
  price_change_match = page.match(/<td class='price-pchange.*?'>([+-]?.+?)<\/td>/)

  if price_change_match
    price_change = price_change_match[1]
    price_change_int = price_change.to_i

    if price_change_int.abs >= ticker[:percentage]
      printf "MICEX: %s / %d / PRICE CHANGE: \e[0;31m%s\e[0m / %s\n" % [ticker[:name], price_change_int, price_change, "http://www.finam.ru/analysis/#{ticker[:profile_id]}"]
      notifyme
    end
  else
    puts 'DID NOT FIND Price Match for %s' % ticker[:name]
  end
end

TICKERS = [
  { name: 'TGK1', profile_id: 'profile047CE', percentage: 0 },
  { name: 'GZPR', profile_id: 'profile041CA', percentage: 0 },
]

TICKERS.each do |ticker|
  micex_run ticker
end; nil

__END__
