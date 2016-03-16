require 'worldize/map'

module Worldize
  describe Map do
    include WebMercator

    def coord2point(lat, lng)
      [lng2x(lng, width), lat2y(lat, height)]
    end
    
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
      context :polygon do
        let(:points){[
          54.567362, 9.501736,
          54.222360, 24.909131,
          51.928793, 33.534639,
          45.002040, 34.522293,
          37.438480, 22.012014,
          37.019071, -4.918006,
          50.610662, -0.177269
        ]}
        let(:points_xy){
          points.each_slice(2).map{|ll| coord2point(*ll)}.flatten
        }
        context 'simple' do
          before{
            map.polygon(*points, color: 'red', fill: 'green')

            Draw.new.stroke('red').fill('green').
              polygon(*points_xy).
              draw(img)
          }
          it{should be_same_image img}
        end

        context 'with hole' do
        end

        context 'with several holes' do
        end
      end

      context :multi_polygon do
      end
    end

    context 'texts' do
      before{
        map.text(*kharkiv, 'Kharkiv', to: :north, font: 'Verdana', size: 10)

        # gravities are WEIRD is hell, but Worldize do well
        #Draw.new.font_family('Verdana').pointsize(10).
          #gravity(NorthGravity).
          #text(*kharkiv_xy, 'Kharkiv').
          #draw(img)
      }
      #it{should be_same_image img}
      it{should_not be_nil}
    end
  end
end
