require 'bundler/setup'
require 'worldize'
require 'csv'
require 'ostruct'

include Math
using Worldize::Refinements

countries = File.read('data/countries.geojson').
        derp{|json| JSON.parse(json)}.
        derp{|hash| Hashie::Mash.new(hash)}.
        features

map = Worldize::Map.new(2000, 2000, background: 'white')
countries.each do |c|
  map.feature(c, fill: '#E0E6FF', color: '#0000FF')
end

capitals = CSV.read(File.expand_path('../data/population_by_capital.csv', __FILE__), headers: true, converters: [:integer, :float]).
            map{|row| OpenStruct.new(row.to_h)}.
            select(&:population) # dropping capitals with population unknown

p capitals.first

max_pop = capitals.map(&:population).max
max_r = 50
max_area = PI*max_r**2

capitals.sort_by(&:population).reverse.each do |row|
  area = row.population.rescale(0..max_pop, 0..max_area)
  r = sqrt(area / PI)
  map.circle(row.lat, row.lng,
    radius: r, color: 'blue', fill: 'blue',
    transparency: row.population.rescale(0..max_pop, 0..1))
end

capitals.sort_by(&:population).reverse.each do |row|
  map.text(row.lat, row.lng, row.name, to: :north_east, size: 10)
end

map.render.write('examples/output/bubbles.png')

