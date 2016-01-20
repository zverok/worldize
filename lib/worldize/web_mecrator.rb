# Formulae: http://wiki.openstreetmap.org/wiki/Mercator
# ...and somehow fixed/guessed to work
# Idea of creative usage of Unicode: https://github.com/mbergek/mercator

module Worldize
  module WebMercator
    using Worldize::Refinements
    
    def lng2x(lng, max_x)
      lng.rescale(-180..180, 0..max_x)
    end

    def lat2y(lat, max_y)
      π = Math::PI
      φ = -lat * π / 180
      
      Math.log(Math.tan(π / 4 + φ / 2)).
        rescale(
          -4.75..4.75, # Don't know... just guessed it.
                       # Neither of online-existing formulas of Web merkator helps
          0..max_y)
    end
  end
end
