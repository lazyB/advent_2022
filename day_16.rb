MAX_TIME = 30

class Map
  attr_accessor :valves

  def initialize
    self.valves = {}
    super
  end

  def add_valve(name, flow, edges)
    if @valves.has_key?(name)
      valve = @valves[name]
      valve.flow = flow
    else
      valve = Valve.new(name, flow)
      @valves[name] = valve
    end
    edges.each do |edge_name|
      edge = @valves[edge_name]
      if edge.nil?
        edge = @valves[edge_name] = Valve.new(edge_name)
      end
      valve.edges[edge_name] = edge
    end
  end
end

class Valve
  attr_accessor :name, :flow, :edges
  def initialize(name, flow = nil)
    self.name = name
    self.flow = flow
    self.edges = {}
  end
end

map = Map.new

File.open("day_16.input").each_line do |line|
  raw_flow, raw_edges = line.split ';'
  flow_parts = raw_flow.split
  name = flow_parts[1]
  flow = flow_parts.last.split('=').last.to_i
  _, _, _, _, *rest = raw_edges.split
  edges = rest.map {|raw| raw.delete (',')}
  map.add_valve(name, flow, edges)
end

puts map

class TravelState
  attr_accessor :current_valve, :traveled_valve, :time_elapsed, :total_flow_rate, :open_valves,
                :total_flow_amount

  def initialize(current_valve)
    self.current_valve = current_valve
    super
  end

  def avail_edges
    new_edges = self.current_valve.edges.reject {|edge| self.traveled_valve.contains? edge }
    all_edges = self.current_valve.edges - new_edges
    new_edges + all_edges
  end

  def open_valve
    new_map = self.clone
    new_map.time_elapsed += 1
    new_map.total_flow_amount += new_map.total_flow_rate
    new_map.total_flow_rate += self.current_valve.flow
    new_map.open_valves = self.open_valves.clone
    new_map.open_valves << self.current_valve
    new_map.traveled_valve = self.traveled_valve.clone
  end

  def travel_edge(edge)
    new_flow = self.total_flow_amount + self.total_flow_rate
    new_time = self.time_elapsed + 1
    new_map = self.clone
    new_map.total_flow_amount = new_flow
    new_map.time_elapsed = new_time
    new_map.current_valve = edge
    new_map.traveled_valve << edge
    new_map
  end

  def spider
    return self.total_flow_amount if self.time_elapsed == MAX_TIME

    if !open_valves.include? self.current_valve
      # open valve somehow
    else
      avail_edges.each {|e|
        travel_edge(e)

}
    end
  end
end