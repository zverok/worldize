require 'bundler/setup'
require 'rmagick'
require 'json'
require 'hashie'
require 'rgb'

module Worldize
  class Countries
    include Magick

    DEFAULT_OPTIONS = {
      width: 2056,
      ocean: 'white',
      land: '#E0E6FF',
      border: '#0000FF'
    }

    DATA_PATH = File.expand_path('../data/countries.geojson', __FILE__)

    refine Object do
      def derp
        yield self
      end
    end

    def initialize
      @countries = File.read(DATA_PATH).
        derp{|json| JSON.parse(json)}.
        derp{|hash| Hashie::Mash.new(hash)}.
        features.map{|country|
          country.polygons =
            country.geometry.coordinates.
              derp{|polys|
                country.geometry.type == 'MultiPolygon' ? polys.flatten(1) : polys
              }.map(&:reverse) # GeoJSON has other approach to lat/lng ordering

          country
        }
    end

    def country_codes
      @countries.map{|c| c.properties.iso_a3}
    end

    def country_names
      @countries.map{|c| c.properties.name}
    end

    def draw(color_by_country, **options)
      img = Image.new(width, width){
        self.background_color = empty_bg
      }

      gc = Magick::Draw.new.
        stroke(stroke).stroke_width(1).
        fill(default_country_bg)

      countries.each do |country|
        draw_country(gc, country, width, country_bg)
        gc.fill(default_country_bg)
      end

      gc.draw(img)

      # really meaningful lat: -63..83, everything else is, in fact, poles
      ymin = lat2y(84, width)
      ymax = lat2y(-63, width)

      img.crop(0, ymin, width, ymax-ymin)
    end

    def draw_selected(*countries, **options)
      selected_color = options.delete(:background) || DEFAULT_SELECTED_COLOR
      # todo: check countries to existance
      draw(countries.map{|c| [c, selected_color]}.to_h, **options)
    end

    def draw_gradient(from_color, to_color, value_by_country, **options)
      # make gradient for known countries
      # use default background for others

      
    end

    private

    include WebMercator

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
