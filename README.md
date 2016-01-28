Worldize
========

**Worldize** is a very simple and naive gem to make world map, with
countries painted according to some values (see also
[choropleth map](https://en.wikipedia.org/wiki/Choropleth_map)).

## Demonstration

### Just monochrome countries

**Code:**
```ruby
worldize = Worldize::Countries.new
img = worldize.draw # Magick::Image of RMagick
img.write('blank.png')
```

**Picture:**
<img src="https://raw.github.com/zverok/worldize/master/examples/output/blank.png" alt="Monochrome countries"/>

You can set some options (see [Usage](#usage) for details):
```ruby
worldize = Worldize::Countries.new
img = worldize.draw(ocean: '#3A3C3C', land: 'black', border: 'yellow')
img.write('night.png')
```
<img src="https://raw.github.com/zverok/worldize/master/examples/output/styles.png" alt="Styles"/>

### Some countries highlighted

**Code:**
```ruby
Worldize::Countries.new.
  draw_highlighted('Ukraine', 'Argentina', 'Portugal', 'India', 'Iceland').
  write('highlighted.png')
```

**Picture:**
<img src="https://raw.github.com/zverok/worldize/master/examples/output/highlighted.png" alt="Highlighted countries"/>

### Countries painted in custom colors

**Code:**
```ruby
Worldize::Countries.new.
  draw(
    'Ukraine' => '#FCF83D',
    'Argentina' => '#FE7ECD',
    'Portugal' => '#FD1F30',
    'India' => '#108400',
    'Iceland' => 'white'
  ).
  write('colors.png')
```

**Picture:**
<img src="https://raw.github.com/zverok/worldize/master/examples/output/colors.png" alt="Countries in different colors"/>

### Countries painted in gradient according to value

```ruby
worldize = Worldize::Countries.new

# create hash like {country name => value}
values = {
  'Argentina' => 100,
  'Bolivia' => 50,
  'Chile' => 180
  #...
}

worldize.
  draw_gradient(
    '#D4F6C8', # gradient from this color
    '#247209', # ...to that color
    values     # ...according to value
    ).
  write('gradient.png')
```
**Picture:**
<img src="https://raw.github.com/zverok/worldize/master/examples/output/gradient.png" alt="Countries gradient"/>

**NB:** on this picture, countries associated with values according to
their position in sorted countries list, just like this:
```ruby
values = worldize.country_names.sort.each_with_index.to_a.to_h
# => {"Afghanistan"=>0, "Albania"=>1, "Algeria"=>2, "Angola"=>3, "Antarctica"=>4, "Argentina"=>5, "Armenia"=>6, ...
```

## Installation

It's gem, named `worldize`. Do your usual `[sudo] gem install worldize`
or adding `gem 'worldize'` to Gemfile routine.

## Usage

### From code

Create an object: `w = Worldize::Countries.new`.

#### Generic draw

Synopsys: `#draw('Country1' => 'color1', 'Country2' => 'color2', ... , option: value)`

`Country` can be either full name or
[ISO 3-letter code](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3).
For list of known names/codes there are service functions `#country_names`
and `#country_codes`.

`color` is any color value RMagick [can understand](http://www.imagemagick.org/script/color.php)
(for ex., hex-codes or common color names).

Options awailable:

* `width` of resulting image (default 1024 pixels, height will be
  calculated automatically);
* `land`—default color of land (for countries not specified in list);
* `ocean`—color of ocean;
* `border`—color of country borders.

Both countries and options can be omitted completely (resulting in
all countries being drawn in default color).

#### Select several countries with one color

Synopsys: `#draw_selected('Country1', 'Country2', ... , option: value)`.

Options are the same as for `#draw` plus `:selected` background color
(reasonable default exists, so can be omitted).

#### Paint countries proportionally to some measurement

Synopsys: `#draw_gradient('from_color', 'to_color', 'Country1' => value1, 'Country2' => value2, ... option: value)`

Values should be numeric and colors will be scaled to gradient between
`from_color` and `to_color`.

### From command line

Use `worldize --help` for details.

**Highlight countries:**
```
worldize -o highlighted.png \
  --highlight-countries Ukraine,Argentina,Portugal,India,Iceland 
```

**Colors for countries:**
```
worldize -o color.png \
  --paint-countries "Ukraine:#FCF83D,Argentina:#FE7ECD,Portugal:#FD1F30,India:#108400,Iceland:white" 
```
or from CSV file
```
worldize -o color.png \
  --paint-countries country_colors.csv --csv-columns 0,1 
```
means firs and second columns contain country name and color. Or from CSV
with headers:
```
worldize -o color.png \
  --paint-countries country_colors.csv
  --csv-headers --csv-columns Country,Color 
```

**Color-coded statisitcs**
```
worldize  -o gradient.png \
  --from-color '#D4F6C8' --to-color '#247209' \
  --grad-countries "Argentina:100,Bolivia:50,Chile:180"
```
or from CSV file, like above:
```
worldize  -o gradient.png \
  --from-color '#D4F6C8' --to-color '#247209' \
  --grad-countries country_stats.csv --csv-headers --columns "Country,Population 2015"
```

## How this was done

* Country borders are taken from [geojson](http://data.okfn.org/data/datasets/geo-boundaries-world-110m)
  (sourced from Natural Earth by OpenData license);
* Web Mercator map projection calculated according to [formulae](https://en.wikipedia.org/wiki/Web_Mercator#Formulas);
* Result is cropped to exclude polar areas (which has nothing interesting
  in any case!);
* RMagick for drawing, awesome [color](https://rubygems.org/gems/color/versions/1.8)
  gem for gradients calculation.

## TODO

_(or not TODO, depends on whether somebody needs this)_

* Options to draw legend and other text labels;
* Use of some open-licensed tiles/picture of the world as background
  image.

## Authors

[Victor Shepelev](http://zverok.github.io/)

## License

MIT.
