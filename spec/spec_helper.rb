require 'rmagick'
include Magick

RSpec::Matchers.define :be_same_image do |expected|
  def diff_tolerance
    0.1
  end
  
  match do |actual|
    expected.rows == actual.rows &&
      expected.columns == actual.columns &&
      expected.difference(actual).first < diff_tolerance
  end

  failure_message do |actual|
    if expected.rows == actual.rows && expected.columns == actual.columns
      FileUtils.mkdir_p 'spec/diffs'
      comparison = Image.new(actual.columns * 3 + 4, actual.rows){|i| i.background_color = 'black'}
      comparison.composite!(actual, 0, 0, CopyCompositeOp)
      comparison.composite!(expected, actual.columns + 2, 0, CopyCompositeOp)
      diff = actual.composite(expected, 0, 0, DifferenceCompositeOp)
      comparison.composite!(diff, actual.columns*2 + 4, 0, CopyCompositeOp)

      # TODO: diff image name calculated from current example name
      # TODO: write Actual, Expected, Difference under images
      comparison.write('spec/diffs/diff.png')

      
      "images are different, see comparison at spec/diffs/diff.png"
    else
      "expected images to be same size, %ix%i != %ix%i" %
        [actual.columns, actual.rows, expected.columns, expected.rows]
    end
  end
end
