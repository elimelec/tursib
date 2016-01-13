require 'nokogiri'
require 'open-uri'

routes = Nokogiri::HTML(open("http://tursib.ro/en/trasee"))
routes = routes.css("div.section table.table1 tr")

routes.each do |route|
	number = route.css("td.cod a").first.content
	name = route.css("td.denumire a").first.content
	p "#{number}: #{name}"
end

