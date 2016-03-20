module Worldize
  class Palette
    def self.make(source)
      case source
      when Palette
        source
      when String
        ConstantPalette.new(source)
      when Array
        ListPalette.new(*source)
      when Range
        GradientPalette.new(source)
      else
        fail ArgumentError, "Can't coerce #{source.class} to Palette"
      end
    end
    
    def first
      pct(0)
    end

    def last
      pct(100)
    end

    def pct(percent)
      (0..100).cover?(percent) or
        fail(ArgumentError, "Expected 0..100 value, #{percent} received")

      at_pct(percent).html
    end

    protected

    def at_pct(*)
      fail NotImplementedError
    end
  end
  
  class ConstantPalette < Palette
    def initialize(color)
      @color = Color::RGB.by_css(color)
    end

    protected
    
    def at_pct(*)
      @color
    end
  end

  class ListPalette < Palette
    def initialize(*colors)
      @colors = colors.map(&Color::RGB.method(:by_css))
    end

    protected
    
    def at_pct(pct)
      @colors[(pct / 100.0 * (@colors.count-1)).round]
    end
  end

  class GradientPalette < Palette
    def initialize(colors)
      colors.is_a?(Range) or
        fail(ArgumentError, "Expected argument to be a range, #{colors.class} got")

      @from = Color::RGB.by_css(colors.begin)
      @to = Color::RGB.by_css(colors.end)
    end

    protected

    def at_pct(pct)
      @from.mix_with(@to, 100 - pct)
    end
  end
end
