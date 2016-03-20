module Worldize
  class World < Map
    DEFAULT_WIDTH = 1024
    DEFAULT_COLORS = {
      ocean: 'white',
      land: '#E0E6FF',
      border: '#0000FF',
      palette: '#5D7BFB'
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

    def countries(value_by_country = nil, **options)
      # NB: syntax countries(value_by_country = {}, **options) causes segfault in Ruby 2.2.0
      value_by_country ||= {}
      options = DEFAULT_COLORS.merge(options)
      border = options.fetch(:border)
      palette = Palette.make(options.fetch(:palette))
      
      colored = value_by_country.select{|_, value| value.is_a?(String)}
      measured = value_by_country.select{|_, value| value.is_a?(Numeric)}
      highlighted = value_by_country.select{|_, value| value.is_a?(TrueClass)}

      highlighted = highlighted.
        map{|country, _| [country, palette.first]}.to_h

      min = measured.values.min
      max = measured.values.max
      measured = measured.
        map{|country, value| [country, palette.pct(value.rescale(min..max, 0..100))]}.
        to_h

      countries = colored.
        merge(highlighted).
        merge(measured)


      @countries.each do |country|
        bg = countries[country.properties.name] ||
              countries[country.properties.iso_a3] ||
              options.fetch(:land)
              
        feature(country.geometry, color: border, fill: bg)
      end

      self
    end

    def render
      # really meaningful lat: -63..83, everything else is, in fact, poles
      ymin = lat2y(84, width)
      ymax = lat2y(-63, width)
      
      super.crop(0, ymin, width, ymax-ymin, true)
    end
  end
end
