require 'bundler/setup'
require 'worldize'
require 'csv'
require 'ostruct'

include Math
using Worldize::Refinements

countries =
  File.read('data/countries.geojson').
        derp{|json| JSON.parse(json)}.
        derp{|hash| Hashie::Mash.new(hash)}.
        features

capitals =
  CSV.read(File.expand_path('../data/population_by_capital.csv', __FILE__), headers: true, converters: [:integer, :float]).
      map{|row| OpenStruct.new(row.to_h)}.
      select(&:population) # dropping capitals with population unknown

map = Worldize::World.new(width: 2000, ocean: 'white')

map.
  countries.
  bubbles(
    capitals.map{|r| [[r.lat, r.lng], r.population]}.to_h,
    color: 'blue',
    max_radius: 60
  )

capitals.sort_by(&:population).reverse.each do |row|
  map.text(row.lat, row.lng, row.name, to: :north_east, size: 10, style: :normal)
end

map.render.write('examples/output/bubbles.png')

