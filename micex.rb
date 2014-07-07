#!/usr/bin/env ruby -w
# encoding: utf-8

# Help
# http://www.finam.ru/analysis/leaders/
#
# Start
# WHEN=today|yesterday ruby ./$0.rb
#

require 'json'
require 'open-uri'
require_relative 'notifyme'
require_relative './tickers'

module MicexFeed
  module_function

  def url
    {
      'yesterday' => 'http://www.finam.ru/service.asp?name=leaders&action=grid&leadersmode=0&market=1&pitch=1&sorting.name=price-pchange&sorting.dir=asc&count=-1',
      'today'     => 'http://www.finam.ru/service.asp?name=leaders&action=grid&leadersmode=0&market=1&pitch=5&sorting.name=price-pchange&sorting.dir=asc&count=-1',
    }.fetch ENV['WHEN']
  end
end

ConsoleView = Struct.new(:instrument_name, :price_diff, :instrument_url) do
  def to_s
    format "%s %s: %s %60s\n",
      Time.now.strftime('%H:%m:%S').ljust(20, ' '),
      instrument_name.ljust(40, '.'),
      price_with_color,
      instrument_url
  end

  def price_with_color
    str = price_diff.to_f < 0 ? "\e[0;31m" : "\e[0;32m"
    str.concat(price_diff).concat("\e[0m")
  end
end

if $0 == __FILE__
  fail ArgumentError, 'provide WHEN=yesterday|today environment variable' unless ENV['WHEN']

  def micex_run(ticker)
    # @page.encode! Encoding::UTF_8, invalid: :replace, replace: ''

    page = @page.match(/#{ticker[:profile_id]}.+?(?=<\/tr)/).to_s
    price_diff_match = page.match(/<td class='price-pchange.*?'>([+-]?.+?)<\/td>/)

    if price_diff_match
      price_diff = price_diff_match[1].sub(',', '.')
      price_diff_int = price_diff.to_i

      if price_diff_int.abs >= ticker[:percentage]
        html = sprintf "MICEX: %s / %d / PRICE CHANGE: \e[0;31m%s\e[0m / %s\n" % [ticker[:name], price_diff_int, price_diff, ticker[:url]]

        puts ("\e[0;31m%40s\e[0m" % ["PRICE CHANGE #{Time.now}"]).tr(' ', '=')
        puts html
        puts ("\e[0;31m%40s\e[0m" % ["PRICE CHANGE #{Time.now}"]).tr(' ', '=')

        notifyme html
      else
        print ConsoleView.new(ticker[:name], price_diff, ticker[:url])
      end
    else
      puts 'no price for %s' % ticker[:name]
    end
  end

  loop do
    begin
      @page = open(MicexFeed.url).read
      TICKERS.each { |ticker| micex_run ticker }
      print ("%80s\n" % '').tr(' ', '-')
      sleep 15
    rescue
      puts $!.message
      puts $!.backtrace
      sleep 15
    end
  end

end

__END__
