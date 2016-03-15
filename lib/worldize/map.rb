require_relative 'refinements'
require_relative 'web_mercator'

module Worldize
  class Map
    include Magick
    include WebMercator
    
    def initialize(width, height, **options)
      @img = Image.new(width, height){|i|
          i.background_color = options[:background]
        }
    end

    def inspect
      "#<%s(%ix%i)>" % [self.class, width, height]
    end

    def circle(lat, lng, **options)
      x, y = coord2point(lat, lng)
      radius = options.fetch(:radius, 1)
      Draw.new.tap{|d| set_draw_options(d, options)}.
        circle(x, y, x + radius, y).
        draw(@img)
    end

    def line(from_lat, from_lng, to_lat, to_lng, **options)
      Draw.new.tap{|d| set_draw_options(d, options)}.
        line(*coord2point(from_lat, from_lng), *coord2point(to_lat, to_lng)).
        draw(@img)
    end

    def text(lat, lng, text, **options)
      if gravity = options[:to]
        const = gravity.to_s.capitalize.gsub(/_([a-z])/){|s| $1.upcase} + 'Gravity'
        options[:gravity] = Magick.const_get(const)
      end
      Draw.new.tap{|d| set_draw_options(d, options)}.
        text(*coord2point(lat, lng), text).
        draw(@img)
    end
    
    def width
      @img.columns
    end

    def height
      @img.rows
    end

    def render
      @img
    end

    private

    OPTS = {
      stroke: :stroke,
      fill: :fill,
      width: :stroke_width,
      opacity: :opacity,
      gravity: :gravity,
      size: :pointsize,
      font: :font_family,
    }

    def set_draw_options(draw, options)
      OPTS.each do |key, method|
        val = options[key]
        draw.send(method, val) if val
      end
    end

    def coord2point(lat, lng)
      [lng2x(lng, width), lat2y(lat, height)]
    end
  end
end
