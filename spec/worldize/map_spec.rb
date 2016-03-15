require 'worldize/map'

module Worldize
  describe Map do
    include WebMercator
    
    let(:width){ 200 }
    let(:height){ 200 }
    let(:map){ Map.new(width, height, background: '#E0E6FF') }
    let(:img){ Image.new(width, height){|i| i.background_color = '#E0E6FF'} }

    let(:kharkiv){ [50.004444, 36.231389] }
    let(:kharkiv_xy){ [lng2x(36.231389, width), lat2y(50.004444, height)] }

    let(:kyiv){ [50.45, 30.523333] }
    let(:kyiv_xy){ [lng2x(30.523333, width), lat2y(50.45, height)] }

    subject{map.render}

    context 'blank' do
      it{should be_same_image img}
    end

    describe 'simple primitives' do
      context :circle do
        before{
          map.circle(*kharkiv, radius: 3, stroke: 'red', fill: 'transparent')

          Draw.new.stroke('red').fill('transparent').
            circle(*kharkiv_xy, kharkiv_xy.first + 3, kharkiv_xy.last).
            draw(img)
        }
        it{should be_same_image img}
      end

      context :line do
        before{
          map.line(*kharkiv, *kyiv, stroke: 'red', width: 2)

          Draw.new.stroke('red').stroke_width(2).
            line(*kharkiv_xy, *kyiv_xy).
            draw(img)
        }
        it{should be_same_image img}
      end
    end

    context 'polygons' do
    end

    context 'texts' do
    end
    
    #it 'compares images' do
      #i1 = Image.new(100, 100){|i| i.background_color = 'white'}
      #i2 = Image.new(100, 100){|i| i.background_color = 'white'}

      #d = Draw.new
      #d.stroke('red')
      #d.fill('transparent')
      #d.circle(50, 50, 25, 25)
      #d.draw(i1)

      #d = Draw.new
      #d.stroke('red')
      #d.fill('transparent')
      #d.circle(50, 50, 20, 20)
      #d.draw(i2)

      #expect(i1).to be_same_image i2
    #end
  end
end
