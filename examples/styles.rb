require 'bundler/setup'
require 'worldize'

Worldize::Countries.new(ocean: '#3A3C3C').
  draw(land: 'black', border: 'yellow').
  write('examples/output/styles.png')
