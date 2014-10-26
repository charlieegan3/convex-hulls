require 'croupier'
require_relative "plotter"

def print_graph(points,size)
  data = []
  points.each do |point|
    data.push(point_os(point,1))
  end

  draw_graph(700,700,size,data,[])
end

#dist = Croupier::Distributions.normal
#dist = Croupier::Distributions.gamma
dist = Croupier::Distributions.cauchy

a = dist.each_slice(2).take(1000).to_a
min = a.flatten.min.abs
a.map! {|x| x = [x[0] + min,x[1]+min]}

print_graph(a,a.flatten.max)
p a
