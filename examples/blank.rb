require 'bundler/setup'
require 'worldize'

Worldize::Countries.new.
  draw.write('examples/output/blank.png')
