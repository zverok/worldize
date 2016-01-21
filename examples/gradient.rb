require 'bundler/setup'
require 'worldize'

worldize = Worldize::Countries.new

# simple hash {name => idx}
values = worldize.country_names.sort.
          each_with_index.to_a.to_h

worldize.
  draw_gradient('#D4F6C8', '#247209', values, border: '#103802', ocean: '#C5F0FC').
  write('examples/output/gradient.png')
