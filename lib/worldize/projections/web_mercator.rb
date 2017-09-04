module Worldize
  module Projections
    # Formulae: http://wiki.openstreetmap.org/wiki/Mercator
    # Idea of creative usage of Unicode: https://github.com/mbergek/mercator
    class WebMercator < Base
      using Worldize::Refinements
      include Math

      private

      def impl(φ, λ)
        [λ, log(tan(π / 4 + φ / 2))]
      end
    end
  end
end
