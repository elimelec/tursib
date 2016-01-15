#!/usr/bin/env ruby

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

def find_stops route, stop
	route = "http://tursib.ro/en/traseu/#{route}"
	route = Nokogiri::HTML(open(route))

	going = route.css("div.fl table.statii tr")
	returning = route.css("div.fr table.statii tr")

	links = []
	(going + returning).each do |s|
		s = s.css("td a").first
		next unless s

		name = s.text
		link = s.attribute("href").value

		links.push link if name[/#{stop}/i]
	end

	links.map do |link|
		"http://tursib.ro#{link}"
	end
end

def print_program route, stop
	links = find_stops route,stop
	links.each do |link|
		stop = Nokogiri::HTML(open(link))
		name = stop.css("h2 span").first
		name = name.text + name.next.text
		p name
		p

		hours = stop.css("div.plecari")

		hours.each do |h|
			h =  h.css("div")
			h.each do |h|
				print h.text + " \t "
			end
			puts
			puts
		end
	end
end

route = ARGV[0]
stop = ARGV[1]

if stop
	print_program route, stop
elsif route
	print_route route
else
	print_routes
end

