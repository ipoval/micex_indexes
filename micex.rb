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
require_relative './tickers'

@url = {
  'yesterday' => 'http://www.finam.ru/service.asp?name=leaders&action=grid&market=1&pitch=1&sorting.name=price-pchange&sorting.dir=desc&count=-1',
  'today' => 'http://www.finam.ru/service.asp?name=leaders&action=grid&market=1&pitch=5&sorting.name=price-pchange&sorting.dir=asc&count=-1',
}.fetch ENV['WHEN']

def micex_run(ticker)
  # @page.encode! Encoding::UTF_8, invalid: :replace, replace: ''

  page = @page.match(/#{ticker[:profile_id]}.+?(?=<\/tr)/).to_s
  price_change_match = page.match(/<td class='price-pchange.*?'>([+-]?.+?)<\/td>/)

  if price_change_match
    price_change = price_change_match[1]
    price_change_int = price_change.to_i

    if price_change_int.abs >= ticker[:percentage]
      html = sprintf "MICEX: %s / %d / PRICE CHANGE: \e[0;31m%s\e[0m / %s\n" % [ticker[:name], price_change_int, price_change, ticker[:url]]

      puts ("\e[0;31m%40s\e[0m" % ["ALARM #{Time.now.to_s}"]).tr(" ", "=")
      puts html
      puts ("\e[0;31m%40s\e[0m" % ["ALARM #{Time.now.to_s}"]).tr(" ", "=")

      notifyme html
    else
      print "%s: %s: %s %60s\n" % [Time.now.ctime, ticker[:name].ljust(20, '.'), price_change, ticker[:url]]
    end
  else
    puts 'no price for %s' % ticker[:name]
  end
end

loop do
  begin
    @page = open(@url).read
    TICKERS.each { |ticker| micex_run ticker }
    print ("%80s\n" % "").tr(' ', '-')
    sleep 15
  rescue
    puts $!.message
    puts $!.backtrace
    sleep 15
  end
end

__END__
