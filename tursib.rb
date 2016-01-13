require 'nokogiri'
require 'open-uri'

def print_routes
	routes = Nokogiri::HTML(open("http://tursib.ro/en/trasee"))
	routes = routes.css("div.section table.table1 tr")

	routes.each do |route|
		number = route.css("td.cod a").first.content
		name = route.css("td.denumire a").first.content
		p "#{number}: #{name}"
	end
end

def print_stops stops
	stops.each do |stop|
		stop = stop.css("td a").first
		next unless stop

		name = stop.text 
		number = stop.attribute("href")
		number = number.value[/statie=[0-9]+/][/[0-9]+/]

		p "#{number}: #{name}"
	end
end

def print_route route
	route = "http://tursib.ro/en/traseu/#{route}"
	route = Nokogiri::HTML(open(route))

	going = route.css("div.fl table.statii tr")
	returning = route.css("div.fr table.statii tr")

	print_stops going
	puts
	print_stops returning
end


route = ARGV[0]

if route
	print_route route
else
	print_routes
end

