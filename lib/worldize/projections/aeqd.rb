module Worldize
  module Projections
    class AEqD < Base
      private

      def impl(φ, λ)
        θ = λ
        ρ = π / 2 - φ
        [ρ * sin(θ), -ρ * cos(θ)]
      end
    end
  end
end
