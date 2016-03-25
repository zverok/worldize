require 'bundler/setup'
require 'worldize'

Worldize::World.new.
  countries.render.write('examples/output/blank.png')
