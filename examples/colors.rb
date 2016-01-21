require 'bundler/setup'
require 'worldize'

Worldize::Countries.new.
  draw(
    'Ukraine' => '#FCF83D',
    'Argentina' => '#FE7ECD',
    'Portugal' => '#FD1F30',
    'India' => '#108400',
    'Iceland' => 'white'
  ).
  write('examples/output/colors.png')

