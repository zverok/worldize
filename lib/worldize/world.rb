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

    def countries(value_by_country, **options)
    end
end
