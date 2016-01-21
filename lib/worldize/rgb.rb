# Pull request already merged into rgb gem: https://github.com/plashchynski/rgb/pull/3
# But new gem version was not released :(
module RGB
  class Color
    attr_reader :hue, :saturation, :lightness # HSL

    class << self
      def from_rgb_hex(color)
        color = '#%.6x' % color if color.is_a? Integer
        rgb = color[1,7].scan(/.{2}/).map{ |component| component.to_i(16) }
        from_rgb(*rgb)
      end

      def calc_saturation(max_rgb, min_rgb, delta, lightness)
        if lightness < 0.5
          delta / (max_rgb + min_rgb)
        else
          delta / (2 - max_rgb - min_rgb)
        end
      end

      def from_rgb(*rgb)
        from_fractions(*rgb_to_hsl(*rgb))
      end

      def rgb_to_hsl(*rgb)
        rgb.map!{ |c| c / 255.0 }
        min_rgb, max_rgb = rgb.min, rgb.max
        delta = max_rgb - min_rgb

        lightness = (max_rgb + min_rgb) / 2.0

        if delta < 1e-5
          hue = saturation = 0
        else
          saturation = calc_saturation(max_rgb, min_rgb, delta, lightness)
          deltas = rgb.map{ |c| (((max_rgb - c) / 6.0) + (delta / 2.0)) / delta }

          hue = if (rgb[0] - max_rgb).abs < 1e-5
            deltas[2] - deltas[1]
          elsif (rgb[1] - max_rgb).abs < 1e-5
            (1.0 / 3.0) + deltas[0] - deltas[2]
          else
            (2.0 / 3.0) + deltas[1] - deltas[0]
          end

          hue += 1 if hue < 0
          hue -= 1 if hue > 1
        end
        [hue, saturation, lightness]
      end

      def from_fractions(hue, saturation, lightness)
        new(360 * hue, saturation, lightness)
      end
    end

    def initialize(*hsl)
      self.hue, self.saturation, self.lightness = hsl
    end

    def to_rgb
      m2 = if lightness <= 0.5
        lightness * (saturation + 1)
      else
        lightness + saturation - lightness * saturation
      end

      m1 = lightness * 2 - m2

      [
        hue_to_rgb(m1, m2, hue_percentage + 1.0 / 3),
        hue_to_rgb(m1, m2, hue_percentage),
        hue_to_rgb(m1, m2, hue_percentage - 1.0 / 3)
      ].map { |c| (c * 0xff).round }
    end

    def to_hsl
      [hue, saturation, lightness]
    end

    def to_rgb_hex
      "#" + to_rgb.map {|c| "%02X" % c }.join
    end

    def hue=(value)
      @hue = value % 360
    end

    def saturation=(value)
      @saturation = if value < 0
        0.0
      elsif value > 1
        1.0
      else
        value
      end
    end

    def lightness=(value)
      @lightness = if value < 0
        0.0
      elsif value > 1
        1.0
      else
        value
      end
    end

    def lighten!(amount)
      @lightness += amount / 100.0
    end

    def lighten_percent!(percentage)
      @lightness += (1 - @lightness) * (percentage / 100.0)
    end

    def darken!(amount)
      @lightness -= (amount / 100.0)
      @lightness = 0 if @lightness < 0
      @lightness
    end

    def darken_percent!(percentage)
      @lightness *= 1.0 - (percentage / 100.0)
    end

    def saturate!(amount)
      @saturation += amount / 100.0
    end

    def saturate_percent!(percentage)
      @saturation += (1 - @saturation) * (percentage / 100.0)
    end

    def desaturate!(amount)
      @saturation -= amount / 100.0
    end

    def desaturate_percent!(percentage)
      @saturation *= (1.0 - (percentage / 100.0))
    end

    def invert!
      @hue, @saturation, @lightness = RGB::Color.from_rgb(*self.to_rgb.map{ |c| 255 - c }).to_hsl
    end

    # shamelessly stolen from
    # https://github.com/chriseppstein/compass-colors/blob/master/lib/compass-colors/sass_extensions.rb#L86
    # Though, I've inverted the coefficients, which seems more logical
    def mix!(other, pct = 50.0)
      coeff = pct.to_f / 100.0
      new_rgb = to_rgb.zip(other.to_rgb).map{|c1, c2| (c1 * (1 - coeff)) + (c2 * coeff)}
      h, s, l = self.class.rgb_to_hsl(*new_rgb)
      self.hue, self.saturation, self.lightness = 360*h, s, l
    end

    # define non-bang methods
    [:darken, :darken_percent, :lighten, :lighten_percent, :saturate, :saturate_percent, :desaturate,
      :desaturate_percent, :invert, :mix].each do |method_name|
        define_method method_name do |*args|
          dup.tap { |color| color.send(:"#{method_name}!", *args) }
        end
    end

  private
    def hue_percentage
      hue / 360.0
    end

    # helper for making rgb
    def hue_to_rgb(m1, m2, h)
      h += 1 if h < 0
      h -= 1 if h > 1
      return m1 + (m2 - m1) * h * 6 if h * 6 < 1
      return m2 if h * 2 < 1
      return m1 + (m2 - m1) * (2.0/3 - h) * 6 if h * 3 < 2
      return m1
    end
  end
end
