require 'bundler/setup'
require 'worldize'

world = Worldize::World.new(ocean: '#C5F0FC')

# simple hash {name => idx}
values = world.country_names.sort.
          each_with_index.to_a.to_h

world.
  countries(values, palette: '#D4F6C8'..'#247209', border: '#103802').
  country('UKR', land: '#2F34FF', border: '#F7F218').
  country('Thailand', land: '#0C1D84', border: '#F80303').
  render.write('examples/output/country.png')
