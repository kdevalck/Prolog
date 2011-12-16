# IMPORTANT Change extension of file from .pl to .rb



#!/usr/bin/ruby

require 'optparse'

@@max_distance = 10

@@day_start = 360
@@day_end = 1440

class Node
  attr_accessor :iden, :x, :y, :connected
  @@nr_nodes = 0
  def initialize(x, y)
    @iden = @@nr_nodes
    @x = x
    @y = y
    @connected = []
    @@nr_nodes += 1
  end

  def to_s
    "node(#{@iden}, #{@x}, #{@y})."
  end

  def connect(node)
    edge = @connected.find{|e| e.to == node}
    if edge.nil?
      edge = Edge.new(self, node, random_distance() ) 
      @connected << edge
    end
    return edge
  end
end


class Edge
  attr_accessor :from, :to, :distance
  
  def initialize(from, to, distance)
    @from = from
    @to = to
    @distance = distance.to_i
  end

  def to_s
    "edge(#{from.iden}, #{to.iden}, #{@distance})."
  end
end

# ABUSE: direct use of numeric node IDs.
class Customer
  attr_accessor :id, :earliest, :latest, :from, :to

  def initialize(id, earliest, latest, from, to)
    @id = id
    @earliest = earliest
    @latest = latest
    @from = from
    @to = to
  end

  def to_s
    "customer(#{id}, #{@earliest}, #{@latest}, #{from}, #{to})."
  end
end

def random_earliest_pickup()
  @day = @@day_end - @@day_start
  return @@day_start + rand(@day - 10)
end

def random_latest_pickup(earliest_pickup)
  @remaining_time = @@day_end - earliest_pickup
  return earliest_pickup + rand(@remaining_time)
end
  
def random_from_node(total_nodes)
  return rand(total_nodes -1)
end

def random_to_node(total_nodes,from_node_id)
  loop do
    @to = rand(total_nodes -1)
    break @to if @to != from_node_id
  end
end
  

def random_distance()
  return rand(@@max_distance) + 1
end

class Grid
  attr_accessor :nodes, :width, :height, :edges, :customers
  def initialize(width, height, total_taxis, total_customers)
    @width = width
    @height = height
    @nodes = Array.new(width)
    for w in 0..(width - 1)
      arr = Array.new(height)
      for h in 0..(height - 1)
        arr[h] = Node.new(w,h)
      end
      @nodes[w] = arr
    end
    self.connect_nodes
    @customers = Array.new(total_customers)
    for c in 0..(total_customers-1)
      @earliest_pickup = random_earliest_pickup
      @latest_pickup = random_latest_pickup(@earliest_pickup)
      @total_nodes = width * height
      @from = random_from_node(@total_nodes)
      @to = random_to_node(@total_nodes,@from)
      @customers[c] = Customer.new(c,@earliest_pickup,@latest_pickup,@from,@to)
    end
  end
  
  def connect_nodes
    for w in 0..(@width - 1)
      for h in 0..(@height - 1)
        node = @nodes[w][h]
        node.connect(@nodes[w-1][h]) unless w == 0
        node.connect(@nodes[w+1][h]) unless w == @width - 1
        node.connect(@nodes[w][h-1]) unless h == 0
        node.connect(@nodes[w][h+1]) unless h == @height - 1
      end
    end
  end

  def print_stuff(f)
    f.puts "% TAXIS"
    self.print_taxis(f)
    f.puts ""
    f.puts "% NODES"
    self.print_nodes(f)
    f.puts ""
    f.puts "% EDGES"
    self.print_edges(f)
    f.puts ""
    f.puts "% CUSTOMERS"
    self.print_customers(f)
    "done"
  end
  
  def print_taxis(f)
    for t in 0..124
      f.puts"taxi(#{t})."
    end
  end

  def print_nodes(f)
    @nodes.each{|arr|
      arr.each{|node|
        f.puts node.to_s
      }
    }
  end

  def print_edges(f)
    @nodes.each{|arr|
      arr.each{|node|
        node.connected.each{|edge|
          f.puts edge.to_s
        }
      }
    }
  end   
  
  def print_customers(f)
    @customers.each{|customer|
        f.puts customer.to_s
    }
  end
end

options = {:width => 25, :height => 25, :max_distance => 10, :max_taxis => 125, :max_customers => 250}
optparse = OptionParser.new do |opts|
   # Set a banner, displayed at the top
   # of the help screen.
   opts.banner = "Usage: generate-data.rb [-w width] [-h height] [-m max-distance] [-t max-taxis] [-c max-customers]"
 
   
  opts.on( '-w', '--width NUM', Integer, 'Adjust width' ) do |width|
    options[:width] = width
  end

  opts.on( '-g', '--height NUM', Integer, 'Adjust height' ) do |height|
    options[:height] = height
  end

  opts.on( '-m', '--max-distance NUM', Integer, 'Adjust max-distance' ) do |dist|
    options[:max_distance] = dist
  end

  opts.on( '-m', '--max-taxis NUM', Integer, 'Adjust max-taxis' ) do |dist|
    options[:max_taxis] = dist
  end

  opts.on( '-m', '--max-customers NUM', Integer, 'Adjust max-customers' ) do |dist|
    options[:max_customers] = dist
  end
 
   # This displays the help screen, all programs are
   # assumed to have this option.
   opts.on( '-h', '--help', 'Display this screen' ) do
     puts opts
     exit
   end
 end

optparse.parse!
@@max_distance = options[:max_distance].to_i

g = Grid.new(options[:width], options[:height], options[:max_taxis], options[:max_customers])
File.open('output', 'w') do |f2| 
	g.print_stuff(f2)
end
