require 'bundler/setup'
require 'worldize'

Worldize::Countries.new.
  draw(ocean: '#3A3C3C', land: 'black', border: 'yellow').
  write('examples/output/styles.png')
