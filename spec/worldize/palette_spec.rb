require 'worldize/palette'

module Worldize
  describe ConstantPalette do
    subject{ConstantPalette.new('red')}

    its(:first){should == '#ff0000'}
    its(:last){should == '#ff0000'}

    it 'should have constant pct' do
      expect(subject.pct(10)).to eq '#ff0000'
      expect(subject.pct(90)).to eq '#ff0000'
    end
  end

  describe ListPalette do
    subject{ListPalette.new('red', 'green', 'blue')}

    its(:first){should == '#ff0000'}
    its(:last){should == '#0000ff'}

    it 'should have pct equally splitted' do
      expect(subject.pct(10)).to eq '#ff0000'
      expect(subject.pct(50)).to eq '#008000' # CSS for "green", strangely
      expect(subject.pct(90)).to eq '#0000ff'
    end
  end

  describe GradientPalette do
    let(:from){'#d4f6c8'}
    let(:to){'#247209'}
    let(:from_c){Color::RGB.by_css(from)}
    let(:to_c){Color::RGB.by_css(to)}

    subject{GradientPalette.new(from..to)}

    its(:first){should == from}
    its(:last){should == to}

    it 'should have pct equally splitted' do
      expect(subject.pct(10)).to eq from_c.mix_with(to_c, 90).html
      expect(subject.pct(50)).to eq from_c.mix_with(to_c, 50).html
      expect(subject.pct(90)).to eq from_c.mix_with(to_c, 10).html
    end
  end

  describe Palette do
    context '::make' do
      it 'makes constant by one value' do
        expect(Palette.make('red')).to be_a ConstantPalette
      end

      it 'makes list by array of values' do
        expect(Palette.make(['red', 'green', 'blue'])).to be_a ListPalette
      end

      it 'makes gradient by range' do
        expect(Palette.make('red'..'blue')).to be_a GradientPalette
      end

      it 'just passes through already existing palette' do
        expect(Palette.make(ConstantPalette.new('red'))).to be_a ConstantPalette
      end

      it 'fails otherwise' do
        expect{Palette.make('red' => 'blue')}.to raise_error ArgumentError
      end
    end
  end
end
