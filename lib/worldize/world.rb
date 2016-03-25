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

    def country(name, **options)
      feature = @countries.
        detect{|c| [c.properties.name, c.properties.iso_a3].include?(name)} or
        fail(ArgumentError, "Country not found: #{name}")

      options = DEFAULT_COLORS.merge(options)
      options[:fill] ||= options.fetch(:land)
      options[:stroke] ||= options.fetch(:border)
      
      feature(feature.geometry, **options)

      self
    end

    def countries(values_and_options = {})
      # NB: syntax countries(value_by_country = {}, **options) causes segfault in Ruby 2.2.0
      options, value_by_country  = values_and_options.
        partition{|k, _| k.is_a?(Symbol)}.map(&:to_h)

      options = DEFAULT_COLORS.merge(options)

      border = options.fetch(:border)
      palette = Palette.make(options.fetch(:palette))
      countries = prepare_countries(value_by_country, palette)

      @countries.each do |country|
        bg = countries[country.properties.name] ||
              countries[country.properties.iso_a3] ||
              options.fetch(:land)
              
        feature(country.geometry, stroke: border, fill: bg)
      end

      self
    end

    def bubbles(value_by_place = nil, **options)
      value_by_country ||= {}

      options = DEFAULT_COLORS.merge(options)
      
      max = value_by_place.values.max
      max_r = options.fetch(:max_radius, 50)
      max_area = PI*max_r**2

      color = options.fetch(:color, 'blue')

      value_by_place.sort_by(&:last).reverse.each do |(lat, lng), value|
        area = value.rescale(0..max, 0..max_area)
        r = sqrt(area / PI)
        circle(lat, lng,
          radius: r, color: color,
          transparency: value.rescale(0..max, 0..0.8))
      end

      self
    end

    def render
      # really meaningful lat: -63..83, everything else is, in fact, poles
      ymin = lat2y(84, width)
      ymax = lat2y(-63, width)
      
      super.crop(0, ymin, width, ymax-ymin, true)
    end

    private

    def prepare_countries(value_by_country, palette)
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

      colored.merge(highlighted).merge(measured)
    end
  end
end
