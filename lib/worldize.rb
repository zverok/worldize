require 'bundler/setup'
require 'rmagick'
require 'json'
require 'hashie'
require 'color'

require_relative 'worldize/refinements'
require_relative 'worldize/web_mercator'

module Worldize
  class Countries
    include Magick

    DEFAULT_OPTIONS = {
      width: 1024,
      ocean: 'white',
      land: '#E0E6FF',
      border: '#0000FF',
      highlight: '#5D7BFB'
    }

    DATA_PATH = File.expand_path('../../data/countries.geojson', __FILE__)

    using Refinements

    def initialize
      @countries = File.read(DATA_PATH).
        derp{|json| JSON.parse(json)}.
        derp{|hash| Hashie::Mash.new(hash)}.
        features.map{|country|
          parse_country(country)
        }
    end

    def country_codes
      @countries.map{|c| c.properties.iso_a3}
    end

    def country_names
      @countries.map{|c| c.properties.name}
    end

    # NB: syntax draw(countries = {}, **options) causes segfault in Ruby 2.2.0
    def draw(countries_and_options = {})
      options = DEFAULT_OPTIONS.merge(countries_and_options)
      width = options.fetch(:width)
      
      img = Image.new(width, width){
        self.background_color = options.fetch(:ocean)
      }

      gc = Magick::Draw.new.
        stroke(options.fetch(:border)).stroke_width(1).
        fill(options.fetch(:land))

      @countries.each do |country|
        bg = countries_and_options[country.properties.name] ||
              countries_and_options[country.properties.iso_a3] ||
              options.fetch(:land)
        draw_country(gc, country, width, bg)
        gc.fill(options.fetch(:land))
      end

      gc.draw(img)

      # really meaningful lat: -63..83, everything else is, in fact, poles
      ymin = lat2y(84, width)
      ymax = lat2y(-63, width)

      img.crop(0, ymin, width, ymax-ymin, true)
    end

    def draw_highlighted(*countries, **options)
      highlight_color = options.fetch(:highlight, DEFAULT_OPTIONS[:highlight])
        
      draw(countries.map{|c| [c, highlight_color]}.to_h.merge(options))
    end

    def draw_gradient(from_color, to_color, value_by_country, **options)
      min = value_by_country.values.min
      max = value_by_country.values.max
      from = ::Color::RGB.by_css(from_color)
      to   = ::Color::RGB.by_css(to_color)

      values = value_by_country.
        map{|country, value| [country, value.rescale(min..max, 0..100)]}.
        map{|country, value| [country, from.mix_with(to, 100 - value).html]}.
        to_h

      draw(values.merge(options))
    end

    def inspect
      "#<#{self.class}>"
    end

    private

    include WebMercator

    def parse_country(country)
      country.polygons =
        country.geometry.coordinates.
          derp{|polys|
            country.geometry.type == 'MultiPolygon' ? polys.flatten(1) : polys
          }.map(&:reverse) # GeoJSON has other approach to lat/lng ordering

      country
    end

    def draw_country(gc, country, width, bg)
      gc.fill(bg)

      country.polygons.each do |poly|
        polygon = poly.map(&:reverse).
          map{|lat, lng| [lng2x(lng, width), lat2y(lat, width)]}
          
        gc.polygon(*polygon.flatten)
      end
    end
  end
end

require_relative 'worldize/web_mercator'
require_relative 'worldize/refinements'
