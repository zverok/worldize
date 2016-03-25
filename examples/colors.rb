require 'bundler/setup'
require 'worldize'

Worldize::World.new.
  countries(
    'Ukraine' => '#FCF83D',
    'Argentina' => '#FE7ECD',
    'Portugal' => '#FD1F30',
    'India' => '#108400',
    'Iceland' => 'white'
  ).render.
  write('examples/output/colors.png')

