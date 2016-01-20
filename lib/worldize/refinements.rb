module Worldize
  module Refinements
    refine Range do
      def distance
        self.end - self.begin
      end
    end

    refine Numeric do
      def rescale(from, to)
        (self - from.begin).to_f / from.distance * to.distance + to.begin
      end
    end
  end
end
