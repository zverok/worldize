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

      self
    end

    def line(from_lat, from_lng, to_lat, to_lng, **options)
      Draw.new.tap{|d| set_draw_options(d, options)}.
        line(*coord2point(from_lat, from_lng), *coord2point(to_lat, to_lng)).
        draw(@img)

      self
    end

    def polygon(*polygons, **options)
      polygons.all?{|poly|
        poly.is_a?(Array) &&
          poly.all?{|n| n.is_a?(Numeric)} &&
          (poly.count % 2).zero?
      } or fail('Expected one or several arrays of points [x1, y1, x2, y2....]')

      path = polygons.map{|poly|
        svg_polygon(poly.each_slice(2).map{|ll| coord2point(*ll)})
      }.join("\n")
      
      Draw.new.tap{|d| set_draw_options(d, options)}.
        path(path).
        draw(@img)

      self
    end

    def text(lat, lng, string, **options)
      x, y = coord2point(lat, lng)
      draw = Draw.new.
        tap{|d| set_draw_options(d, options)}
      

      dw = dh = 0
      if gravity = options[:to]
        # ImageMagick gravity is REALLY PRETTY WEIRD, at least in this context
        #const = gravity.to_s.capitalize.gsub(/_([a-z])/){|s| $1.upcase} + 'Gravity'
        #options[:gravity] = Magick.const_get(const)

        metrics = draw.get_type_metrics('{' + string + '}')
        gravity.to_s.split(/_/).each do |component|
          case component
          when 'north'
            dh = -metrics.height/2
          when 'south'
            dh = metrics.height/2
          when 'east'
            dw = metrics.width/2
          when 'west'
            dw = -metrics.width/2
          when 'center'
            # no translation
          else
            fail ArgumentError, "Unknown gravity component #{component}"
          end
        end
      end
      draw.
        translate(x + dw, y + dh).
        text_align(CenterAlign).gravity(CenterGravity).
        text(0, 0, string).
        draw(@img)

      self
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
      color: :stroke
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

    def svg_polygon(points)
      [
        'M%f,%f' % points.first,
        *points[1..-1].map{|p| 'L%f,%f' % p},
        'Z'
      ].join(' ')
    end
  end
end
