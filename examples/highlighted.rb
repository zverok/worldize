require 'bundler/setup'
require 'worldize'

Worldize::Countries.new.
  draw_highlighted('Ukraine', 'Argentina', 'Portugal', 'India', 'Iceland').
  write('examples/output/highlighted.png')
