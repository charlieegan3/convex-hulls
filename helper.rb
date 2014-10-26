# method to split an array in 2 halves
# http://stackoverflow.com/a/13634446/1510063
class Array; def in_groups(num_groups)
  return [] if num_groups == 0
  slice_size = (self.size/Float(num_groups)).ceil
  self.each_slice(slice_size).to_a
end; end

# my random points method, given a required number and a grid size it returns a list of [x,y] pairs
def set_points(count,size)
  if count > size
    raise "Whow there!"
  end
  points = []
  x = (0..size-1).to_a.shuffle
  y = (0..size-1).to_a.shuffle
  begin
    points.push([x.shift,y.shift])
  end until points.size == count
  points
end

# print a set of coordinate points on a grid, reccomended only for small numbers of points
def print_grid(points,size)
  grid = []
  for i in 0..size-1
    grid.push([])
    for j in 0..size-1
      if points.include? [j,i]
        # grid.last.push("#{j.to_s.reverse[0]}#{i.to_s.reverse[0]}")
        grid.last.push("#{j}#{i}")
      else
        grid.last.push("__")
      end
    end
  end
  grid.reverse!
  grid.map {|x| puts x.join(" ")}
end

# plots points as x's on a monospaced grid
def print_points(points,size)
  grid = []
  for i in 0..size-1
    grid.push([])
    for j in 0..size-1
      if points.include? [j,i]
        grid.last.push("x")
      else
        grid.last.push(".")
      end
    end
  end
  grid.reverse!
  grid.map {|x| puts x.join(" ")}
end

# same as above but for larger datasets, best to use the print_graph method at this stage
def print_fine_points(points,size)
  grid = []
  for i in 0..size-1
    grid.push([])
    for j in 0..size-1
      if points.include? [j,i]
        grid.last.push("x")
      else
        grid.last.push(".")
      end
    end
  end
  grid.reverse!
  grid.map {|x| puts x.join("")}
end

# exports the hull and all the points to an svg file using the methods in plotter.rb
def print_graph(hull,points,size)
  lines = []
  hull.each do |line|
    lines.push([point_os(line.first,5),point_os(line.last,5)])
  end
  h_points = hull_points(hull)
  points = points - h_points

  data = []
  points.each do |point|
    data.push(point_os(point,0.1))
  end
  h_points.each do |point|
    data.push(point_os(point,10))
  end

  draw_graph(700,700,size,data,lines)
end

# my own partition method that sorts the points by x coordinate first
def partition_points(points)
  points.sort_by! {|x| x[0]} #why I think my algorithm needs to be nlogn
  return points.in_groups(2)
end

# method to evaluate the turn orientation of 3 points
# http://youtu.be/0HZaRu5IupM?t=12m20s
def turn(points)
  if points.any? {|x| x.nil?} #if less than 3 points
    return true
  end
  p1 = points[0]
  p2 = points[1]
  p3 = points[2]
  area = (p2[0]-p1[0])*(p3[1]-p1[1]) - (p2[1]-p1[1])*(p3[0]-p1[0])
  if area < 0; return true #clock
  elsif area > 0; return false #anti
  else; return "collinear"; end
end

# methods to evaluate the starting points when comparing two hulls.
def left_most(points)
  (points.sort_by! {|x| x[0]}).first
end
def right_most(points)
  (points.sort_by! {|x| x[0]}).last
end

# calculate the gradient of a line from two points
def gradient(point1,point2)
  ((point1[1] - point2[1]).to_f/(point1[0] - point2[0]))
end

# methods to calculate the next point to move to given a point and a hull
# this methods could likely be merged
def next_anti_point(hull, point, visited)
  hull = hull.select {|x| x.include? point}
  nexts = hull_points(hull) - [point] - visited
  points = [point,nexts[0],nexts[1]]
  if turn(points) == true
    points = [point,nexts.last,nexts.first]
  end
  return points[1] || point
end

def next_clock_point(hull, point, visited)
  hull = hull.select {|x| x.include? point}
  nexts = hull_points(hull) - [point] - visited
  points = [point,nexts.first,nexts.last]
  if turn(points) == false
    points = [point,nexts.last,nexts.first]
  end
  return points[1] || point
end

# methods used when testing if a line is a upper or lower common tangent
# again, these methods should really be merged
def above_line(line,point)
  grad = gradient(line.first,line.last)
  c = grad * -1 * line.first[0] + line.first[1]
  line_y = grad * point[0] + c
  diff = point[1] - line_y
  if diff > -0.000000001 # i'm sure there's something wrong with this!
    return true
  else
    return false
  end
end

def below_line(line,point)
  grad = gradient(line.first,line.last)
  c = grad * -1 * line.first[0] + line.first[1]
  line_y = grad * point[0] + c
  diff = line_y - point[1]
  if diff > -0.000000001
    return true
  else
    return false
  end
end

# hulls are stored as a list of lines, this gets the uniq points from those lines
def hull_points(hull)
  points = []
  hull.map {|x| points.push(x[0],x[1])}
  points.uniq
end

# checking if a tangent qualifies as an upper or lower tangent
# checks that each point is above or below the line
def upper_tangent(hull,line)
  points = hull_points(hull) - line
  return points.all? {|x| below_line(line,x)}
end
def lower_tangent(hull,line)
  points = hull_points(hull) - line
  return points.all? {|x| above_line(line,x)}
end

# my interpretation of the given pseudocode
# calcuates the upper common tangent for two hulls
def uct(hull1,hull2)
  hull = hull1 + hull2
  edge = [right_most(hull_points(hull1)),left_most(hull_points(hull2))]
  list = []
  list.push(edge)
  visited = [edge.first,edge.last]
  while upper_tangent(hull,edge) == false do
    while upper_tangent(hull1,edge) == false do
      edge = [next_anti_point(hull1, edge[0],visited),edge[1]]
      visited.push(edge.first)
      list.push(edge)
    end
    while upper_tangent(hull2,edge) == false do
      edge = [edge[0],next_clock_point(hull2, edge[1],visited)]
      upper_tangent(hull2,edge)
      visited.push(edge.last)
      list.push(edge)
    end
  end

  list.map {|x| visited.push(x[0],x[1])}
  visited.uniq #deletion canditatates
  return edge, visited
end

# the reverse of upper common tangent
def lct(hull1,hull2)
  hull = hull1 + hull2
  edge = [right_most(hull_points(hull1)),left_most(hull_points(hull2))]
  list = []
  list.push(edge)
  visited = [edge.first,edge.last]
  while lower_tangent(hull,edge) == false do
    while lower_tangent(hull1,edge) == false do
      edge = [next_clock_point(hull1, edge[0],visited),edge[1]]
      visited.push(edge.first)
      list.push(edge)
    end
    while lower_tangent(hull2,edge) == false do
      edge = [edge[0],next_anti_point(hull2, edge[1],visited)]
      visited.push(edge.last)
      list.push(edge)
    end
  end
  list.map {|x| visited.push(x[0],x[1])}
  visited.uniq #deletion canditatates
  return edge, visited
end

def merge_hull(hull1,hull2)
# puts hull_points(hull1).size.to_s + " " + hull_points(hull2).size.to_s #print the size of each hull being merged.
# print "." #I used these as a progress indicator diring testing
  time = Time.new
  upper = uct(hull1,hull2)
  log("upp_c_t", Time.new - time) #adding a record to the log file that aggregates the time
# print ":"
  time = Time.new
  lower = lct(hull1,hull2)
  log("low_c_t", Time.new - time)

  time = Time.new
  upper_common = upper[0]#first value is the uct, second [1] is the visited points
  lower_common = lower[0]
  redundant_points = ((upper[1]+lower[1]) - (upper_common + lower_common)).uniq

  hull = hull1 + hull2 + [upper_common] + [lower_common] #create the new hull with our uct and lct
# count = hull_points(hull).size #used to count number of removed points each time.
  #tidy up the old lines and points
  hull.reject! {|x| (x - redundant_points).size < x.size}
  hull.reject! {|x| (upper_tangent(hull,x) || lower_tangent(hull,x)) == false}
# puts (hull_points(hull).size.to_f/count).to_f
  log("merging", Time.new - time)
  return hull
end

def get_hull(points)
  if points.size < 4 #base case
    return points.combination(2).to_a
  else
    time = Time.new
    p1,p2 = partition_points(points)
    log("partitioning", Time.new - time)
    return merge_hull(get_hull(p1),get_hull(p2))#merge using recursion
  end
end

# methods to manage the timing log
def log(job,time)
  open('log.txt', 'a') { |f|
    f.puts job + "," + time.to_s
  }
end

def clear_log
  open('log.txt', 'w') { |f|
    f.print ""
  }
end

def print_log
  puts "\nLOG\n====="
  times = Hash.new(0)
  text=File.open('log.txt').read.gsub(/\r\n?/, "\n")
  text.each_line do |line|
    line = line.split(",")
    times[line[0]] += line[1].to_f
  end
  times = times.to_a.sort_by {|x| x[1]}
  times.reverse!
  times.map {|x| puts x[0] + "\t\t" + x[1].round(4).to_s + "s"}
  puts "_____\nTOTAL:\t\t" + (times.map {|x| x = x[1]}).inject(:+).round(2).to_s + "s"
end
