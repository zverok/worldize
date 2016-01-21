require 'bundler/setup'
require 'worldize'

Worldize::Countries.new.
  draw_selected('Ukraine', 'Argentina', 'Portugal', 'India', 'Iceland').
  write('examples/output/selected.png')
