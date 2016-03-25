require 'bundler/setup'
require 'worldize'

Worldize::World.new(ocean: '#3A3C3C').
  countries(land: 'black', border: 'yellow').
  render.write('examples/output/styles.png')
