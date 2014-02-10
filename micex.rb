#!/usr/bin/env ruby -w
# encoding: utf-8

# Help
# http://www.finam.ru/analysis/leaders/

require 'json'
require 'open-uri'

TGK1 = 'profile047CE'
GZPR = 'profile041CA'

def micex_run
  @url = 'http://www.finam.ru/service.asp?name=leaders&action=grid&market=1&pitch=5&sorting.name=price-pchange&sorting.dir=desc&count=-1&price-pchange.min=null&price-pchange.max=null'

  page = open(@url).read
  # page.encode! Encoding::UTF_8, invalid: :replace, replace: ''

  str = page.match(/#{TGK1}.+?(?=<\/tr)/).to_s

  price_change_match = str.match(/<td class='price-pchange.*?'>([+-]?.+?)<\/td>/)

  if price_change_match
    price_change = price_change_match[1]
    price_change_int = price_change.to_i

    if true || price_change_int.abs >= 1
      printf "MICEX: %s / %d / PRICE CHANGE: \e[0;31m%s\e[0m / %s\n" % ['TGK1', price_change_int, price_change, 'http://www.finam.ru/analysis/profile047CE']
    end
  end
end

__END__
