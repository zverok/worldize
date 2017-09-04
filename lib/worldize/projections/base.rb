module Worldize
  module Projections
    class Base
      using Worldize::Refinements
      include Math

      def initialize(xmax, ymax)
        @xmax = xmax
        @ymax = ymax
      end

      def call(lat, lng)
        xrad, yrad = impl(deg2rad(lat), deg2rad(lng))
        [
          xrad.rescale(-π..π, 0..@xmax),
          #@ymax - yrad.rescale(-π..π, 0..@ymax)
          yrad.rescale(-π..π, 0..@ymax)
        ]
      end

      private

      def deg2rad(deg)
        deg * π / 180
      end

      def π
        PI
      end
    end
  end
end
