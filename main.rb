require_relative "helper" # where all the methods are for my project
require_relative "plotter" # generates svg graphs
require 'croupier' # generates random data from different distributions
clear_log

size = 10000
count = size

time = Time.new
puts "Creating Points..."
points = set_points(count,size) # generate points
log("points", Time.new - time)

# you can use these lines of code to generate some other more interesting distributions
# dist = Croupier::Distributions.normal # set size too 10 for plotting
# dist = Croupier::Distributions.gamma # set size too 10 for plotting
# dist = Croupier::Distributions.cauchy # set size too 4000ish for plotting
# points = dist.each_slice(2).take(1000).to_a
# min = points.flatten.min.abs
# points.map! {|x| x = [x[0] + min,x[1]+min]}

puts "Creating Hull..."
hull = get_hull(points) # generate hull using recursion
# puts hull_points(hull).size # show the number of used points.
puts


time = Time.new
puts "Creating Graph..."
print_graph(hull,points,size) # print the svg graph to the plot.html file. this takes a long time.
puts "Graph Saved in plot.html"
log("graph", Time.new - time)

print_log #shows the time breakdown for different parts of the program.
