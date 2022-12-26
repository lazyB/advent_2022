MAX_TIME = 30
PRINT_ENABLED = ENV['PRINT_ENABLED'] || false

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
    valve
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
class TravelState
  attr_accessor :current_valve, :traveled_valve, :time_elapsed, :total_flow_rate, :open_valves,
                :total_flow_amount, :history

  @@cache_hits = 0
  @@cache_misses = 0

  def self.cache_hits
    @@cache_hits
  end

  def self.cache_misses
    @@cache_misses
  end

  def initialize(current_valve)
    self.current_valve = current_valve
    @open_valves = []
    @time_elapsed = 0
    @traveled_valve = [current_valve]
    @history = [current_valve]
    @total_flow_amount = 0
    @total_flow_rate = 0
  end

  def remaining_time
    MAX_TIME - time_elapsed
  end

  def avail_edges
    sorted = self.current_valve.edges.values.sort{|v1, v2| v2.flow <=> v1.flow}
    new_edges = sorted.reject {|edge| self.traveled_valve.include? edge }
    all_edges = sorted - new_edges
    new_edges + all_edges
  end

  def open_valve
    new_state = self.clone
    new_state.time_elapsed += 1
    new_state.total_flow_amount += new_state.total_flow_rate
    new_state.total_flow_rate += self.current_valve.flow
    new_state.open_valves = self.open_valves.clone
    new_state.open_valves << self.current_valve
    new_state.traveled_valve = self.traveled_valve.clone
    new_state
  end

  def travel_edge(edge)
    new_state = self.clone
    new_state.total_flow_amount = self.total_flow_amount + self.total_flow_rate
    new_state.time_elapsed = self.time_elapsed + 1
    new_state.current_valve = edge
    new_state.traveled_valve = @traveled_valve.clone
    new_state.traveled_valve << edge
    new_state.history = @history.clone
    new_state.history << edge
    new_state
  end

  def open_valve_names
    @open_valves.map(&:name).sort.join(",")
  end

  def print_state(force_print = false)
    return unless PRINT_ENABLED || force_print
    puts "time: #{@time_elapsed} rate: #{@total_flow_rate} amount:#{@total_flow_amount} open:#{open_valve_names}"
    puts "history: #{@history.map(&:name).join("->") }"
  end

  def proj_total
    @total_flow_amount + @total_flow_rate * remaining_time
  end

  def spider
    if self.time_elapsed == MAX_TIME
      puts "REACHED END" if PRINT_ENABLED
      print_state
      return self
    elsif fetch_memo(self)
      @@cache_hits += 1
      new_state = self.clone
      new_state.total_flow_amount += fetch_memo(self)
      return new_state
    else
      @@cache_misses += 1
    end

    best_state = self
    if !open_valves.include?(self.current_valve) && @current_valve.flow > 0
      # open valve somehow
      new_state_open = open_valve
      puts"OPEN VALVE #{@current_valve.name}" if PRINT_ENABLED
      new_state_open.print_state
      best_state = new_state_open.spider
    end
    avail_edges.each {|e|
      if @current_valve.name == "AA"
        puts "check A" if PRINT_ENABLED
      end
      puts "from #{@current_valve.name} travel edge #{e.name}" if PRINT_ENABLED
      new_map = travel_edge(e)
      new_state = new_map.spider
      puts "spider state:" if PRINT_ENABLED
      new_state.print_state
      if new_state.total_flow_amount > best_state.total_flow_amount
        puts "NEW BEST STATE" if PRINT_ENABLED
        new_state.print_state
        best_state = new_state
      end
    }
    memoize(best_state, best_state.total_flow_amount - @total_flow_amount)
    return best_state
  end


  @@state_memo ||= {}

  def memoize(state, delta)
    @@state_memo[state.current_valve.name] ||= {}
    @@state_memo[state.current_valve.name][state.open_valve_names] ||= {}
    @@state_memo[state.current_valve.name][state.open_valve_names][remaining_time] = delta
  end

  def fetch_memo(state)
    return nil unless @@state_memo&.[](state.current_valve.name)&.[](state.open_valve_names)
    @@state_memo[state.current_valve.name][state.open_valve_names][remaining_time]
  end

end

first_valve = nil
File.open("day_16.input").each_line do |line|
  raw_flow, raw_edges = line.split ';'
  flow_parts = raw_flow.split
  name = flow_parts[1]
  flow = flow_parts.last.split('=').last.to_i
  _, _, _, _, *rest = raw_edges.split
  edges = rest.map {|raw| raw.delete (',')}
  valve = map.add_valve(name, flow, edges)
  first_valve = valve if first_valve.nil?
end

puts map

initial_state = TravelState.new(first_valve)

answer = initial_state.spider

puts("FINAL ANSWER hits: #{TravelState.cache_hits} misses: #{TravelState.cache_misses}")
answer.print_state