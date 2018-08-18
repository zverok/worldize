require 'bundler/setup'
require 'mini_magick'
require 'json'
require 'hashie'
require 'color'
require 'tempfile'
require 'erb'

require_relative 'worldize/refinements'
require_relative 'worldize/web_mercator'

module Worldize
  class Countries
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

    def template
      template_filename = 'worldize/template.mvg.erb'
      template_path = File.join(File.dirname(__FILE__), template_filename)
      ERB.new(File.read(template_path), nil, '-')
    end

    # MiniMagick cannot ha
    # rubocop:disable Metrics/MethodLength
    def convert_mvg_to_png(input_file, width, ymin, ymax)
      temp = Tempfile.new(['worldize', '.png'])
      begin
        # workaround, there isnt a way to enforce `mvg:filename` decode
        MiniMagick::Tool::Convert.new do |convert|
          convert << "mvg:#{input_file.path}"
          convert << temp.path
        end
        png = MiniMagick::Image.open(temp.path, '.png')
        png.combine_options do |c|
          c.crop "#{width}x#{ymax - ymin}+0+#{ymin}!"
        end
      ensure
        temp.close
        temp.unlink # deletes the temp file
      end
      png
    end
    # rubocop:enable Metrics/MethodLength


    def draw(countries_and_options = {})
      options = DEFAULT_OPTIONS.merge(countries_and_options)
      width = options.fetch(:width)
      # really meaningful lat: -63..83, everything else is, in fact, poles
      ymin = lat2y(84, width)
      ymax = lat2y(-63, width)

      file = Tempfile.new(['worldize', '.mvg'])
      begin
        mvg_content = template.result(binding)
        file.write(mvg_content)
        file.close
        png = convert_mvg_to_png(file, width, ymin, ymax)
      ensure
        file.close
        file.unlink # deletes the temp file
      end
      png
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
  end
end

require_relative 'worldize/web_mercator'
require_relative 'worldize/refinements'
