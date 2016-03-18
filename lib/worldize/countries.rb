module Worldize
  class Countries < Map
    DEFAULT_WIDTH = 1024
    DEFAULT_COLORS = {
      ocean: 'white',
      land: '#E0E6FF',
      border: '#0000FF',
      highlight: '#5D7BFB'
    }

    DATA_PATH = File.expand_path('../../../data/countries.geojson', __FILE__)

    using Refinements

    def initialize(width: DEFAULT_WIDTH, ocean: DEFAULT_COLORS[:ocean])
      super(width, width, background: ocean)
      
      @countries = File.read(DATA_PATH).
        derp{|json| JSON.parse(json)}.
        derp{|hash| Hashie::Mash.new(hash)}.
        features
    end

    def country_codes
      @countries.map{|c| c.properties.iso_a3}
    end

    def country_names
      @countries.map{|c| c.properties.name}
    end

    # NB: syntax draw(countries = {}, **options) causes segfault in Ruby 2.2.0
    def draw(countries_and_options = {})
      options = DEFAULT_COLORS.merge(countries_and_options)

      border = options.fetch(:border)

      @countries.each do |country|
        bg = countries_and_options[country.properties.name] ||
              countries_and_options[country.properties.iso_a3] ||
              options.fetch(:land)
              
        feature(country.geometry, color: border, fill: bg)
      end

      # really meaningful lat: -63..83, everything else is, in fact, poles
      ymin = lat2y(84, width)
      ymax = lat2y(-63, width)

      render.crop(0, ymin, width, ymax-ymin, true)
    end

    def draw_highlighted(*countries, **options)
      highlight_color = options.fetch(:highlight, DEFAULT_COLORS[:highlight])
        
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
  end
end
