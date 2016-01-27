# Formulae: http://wiki.openstreetmap.org/wiki/Mercator
# ...and somehow fixed/guessed to work
# Idea of creative usage of Unicode: https://github.com/mbergek/mercator

module Worldize
  module WebMercator
    using Worldize::Refinements
    include Math
    
    def lng2x(lng, max_x)
      lng.rescale(-180..180, 0..max_x)
    end

    def lat2y(lat, max_y)
      π = PI
      φ = -lat * π / 180
      
      log(tan(π / 4 + φ / 2)).rescale(-π..π, 0..max_y)
    end
  end
end
