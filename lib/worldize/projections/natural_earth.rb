module Worldize
  module Projections
    # See http://www.shadedrelief.com/NE_proj/
    class NaturalEarth < Base
      A0 = 0.8707
      A1 = -0.131979
      A2 = -0.013791
      A3 = 0.003971
      A4 = -0.001529
      B0 = 1.007226
      B1 = 0.015085
      B2 = -0.044475
      B3 = 0.028874
      B4 = -0.005916

      private

      def impl(φ, λ)
        [
          λ * (A0 + φ**2 * (A1 + φ**2 * (A2 + φ**4 * φ**2 * (A3 + φ**2 * A4)))),
          φ * (B0 + φ**2 * (B1 + φ**4 * (B2 + B3 * φ**2 + B4 * φ**4)))
        ]
      end
    end
  end
end
