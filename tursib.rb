#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'

class Route
	attr_accessor :name, :number, :link

	def initialize(route)
		@number = route.css("td.cod a").first.content
		@link = route.css("td.cod a").first.attribute("href").value
		@link = "http://tursib.ro#{@link}"
		@name = route.css("td.denumire a").first.content
	end

	def get_stations
		route = Nokogiri::HTML(open(@link))

		going = route.css("div.fl table.statii tr")
		returning = route.css("div.fr table.statii tr")

		[going, returning]
	end

	def print_stations
		get_stations.each do |stations|
			stations.each do |station|
				station = station.css("td a").first
				next unless station

				name = station.text
				number = station.attribute("href")
				number = number.value[/statie=[0-9]+/][/[0-9]+/]

				puts "#{number}: #{name}"
			end
			puts
		end
	end
end

def print_routes routes
	routes.each do |r|
		puts "#{r.number}: #{r.name}"
	end
end

def get_routes
	routes = Nokogiri::HTML(open("http://tursib.ro/en/trasee"))
	routes = routes.css("div.section table.table1 tr")

	routes.map do |route|
		Route.new route
	end
end

def print_route route
	route = get_routes.find {|r| r.number == route}
	route.print_stations
end

def find_stations route, station
	route = get_routes.find {|r| r.number == route}
	stations = route.get_stations.flatten

	links = []
	stations.each do |s|
		s = s.css("td a").first
		next unless s

		name = s.text
		link = s.attribute("href").value

		links.push link if name[/#{station}/i]
	end

	links.map do |link|
		"http://tursib.ro#{link}"
	end
end

def print_program route, station
	links = find_stations route, station
	links.each do |link|
		station = Nokogiri::HTML(open(link))
		name = station.css("h2 span").first
		name = name.text + name.next.text
		p name
		p

		hours = station.css("div.plecari")

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
station = ARGV[1]

if station
	print_program route, station
elsif route
	print_route route
else
	print_routes get_routes
end

