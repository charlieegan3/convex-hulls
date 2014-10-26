$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'

def point_os(point,weight)
  OpenStruct.new({x: point[0], y: point[1], z: weight})
end

def draw_graph(width,height,range,points,lines)
  x = pv.Scale.linear(0,range).range(0, width)
  y = pv.Scale.linear(0,range).range(0, height)
  c = pv.Scale.log(1, 10).range("black","red")
  vis = pv.Panel.new().width(width).height(height).bottom(20).left(100).right(100).top(5)

  # Show axis and ticks.
  # vis.add(pv.Rule).data(y.ticks()).bottom(y).strokeStyle(lambda {|d| d!=0 ? "#eee" : "#000"}).anchor("left").add(pv.Label).text(y.tick_format)
  # vis.add(pv.Rule).data(x.ticks()).left(x).stroke_style(lambda {|d| d!=0 ? "#eee" : "#000"}).anchor("bottom").add(pv.Label).text(x.tick_format);

  vis.add(pv.Panel).data(points).add(pv.Dot).left(lambda {|d| x.scale(d.x)}).bottom(lambda {|d| y.scale(d.y)}).stroke_style(lambda {|d| c.scale(d.z)}).fill_style(lambda {|d| c.scale(d.z).alpha(0.2)}).shape_size(lambda {|d| d.z}).title(lambda {|d| "%0.1f" % d.z})
  lines.each do |line|
    vis.add(pv.Line).data(line).line_width(0.5).left(lambda {|d| x.scale(d.x)}).bottom(lambda {|d| y.scale(d.y)})
  end

  vis.render()

  File.open("plot.html", 'w') { |file| file.write(vis.to_svg) }
  return
end
