module Worldize
  class Countries < Map
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
      palette = Palette.new(options.fetch(:palette))
      
      colored = value_by_country.select{|_, value| value.is_a?(String)}
      measured = value_by_country.select{|_, value| value.is_a?(Numeric)}
      highlighted = value_by_country.select{|_, value| value.is_a?(TrueClass)}

      min = measured.values.min
      max = measured.values.max

      countries = colored.
        merge(highlighted.map{|country, _| [country, palette.first]}.to_h).
        merge(measured.map{|country, value| [country, palette.pct(value.rescale(min..max, 0..100))}.to_h)


      @countries.each do |country|
        bg = countries[country.properties.name] ||
              countries[country.properties.iso_a3] ||
              options.fetch(:land)
              
        feature(country.geometry, color: border, fill: bg)
      end
    end
end
