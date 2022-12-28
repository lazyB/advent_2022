MAX_TIME = 20
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
      edge_valve = @valves[edge_name]
      if edge_valve.nil?
        edge_valve = @valves[edge_name] = Valve.new(edge_name)
      end
      valve.edges[edge_name] = {valve: edge_valve, cost: 1}
    end
    valve
  end

  #TODO THIS IS TOSSING OUT THE EDGE FROM BB -> JJ, WHICH IS CHANGING THE TOPOLOGY AND THAT'S NOT GOOD
  def coalesce_zero_edges
    zero_valves = @valves.values.select{|v| v.flow.zero?}
    zero_valves.each do |zero_v|
      zero_v.edges.each do |k, v|
        valve = v[:valve]
        cost = v[:cost]
        other_edges = zero_v.edges.reject {|name, h| h[:valve].name == valve.name}

        valve.replace_edge(zero_v, other_edges)
      end
      zero_v.edges.each do |k, v|
        valve = v[:valve]
        valve.edges.delete(zero_v.name)
      end
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

  def replace_edge(edge, new_edges)
    deleted_edge = @edges[edge.name]
    if deleted_edge.nil?
      puts "new edge"
    end
    edge_cost = 1
    edge_cost = deleted_edge[:cost] unless deleted_edge.nil?
    new_edges.each do |k, v|
      puts k
      new_valve = v[:valve]
      new_edge_cost = v[:cost] + edge_cost
      next if !edges[k].nil? && edges[k][:cost] <= new_edge_cost
      edges[new_valve.name] = {valve: new_valve, cost: new_edge_cost}
      new_valve.edges[self.name] = {valve: self, cost: new_edge_cost}
    end
  end
end

@map = Map.new
class TravelState
  attr_accessor :current_valve, :traveled_valve, :time_elapsed, :total_flow_rate, :open_valves,
                :total_flow_amount, :history, :map

  @@cache_hits = 0
  @@cache_misses = 0
  @@best_route = nil

  def self.cache_hits
    @@cache_hits
  end

  def self.cache_misses
    @@cache_misses
  end

  def initialize(current_valve, map)
    self.current_valve = current_valve
    @open_valves = []
    @time_elapsed = 0
    @traveled_valve = [current_valve]
    @history = [current_valve]
    @total_flow_amount = 0
    @total_flow_rate = 0
    @map = map
  end

  def remaining_time
    MAX_TIME - time_elapsed
  end

  def avail_edges
    reachable = self.current_valve.edges.values.select{|h| h[:cost] <= remaining_time }
    reachable.sort{|v1, v2| v2[:valve].flow <=> v1[:valve].flow}
             .sort_by{|edge| self.traveled_valve.include? edge[:valve] ? 0 : 1 }
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
    edge_valve = edge[:valve]
    edge_cost = edge[:cost]
    new_state = self.clone
    new_state.total_flow_amount = self.total_flow_amount + self.total_flow_rate
    new_state.time_elapsed = self.time_elapsed + edge_cost
    new_state.current_valve = edge_valve
    new_state.traveled_valve = @traveled_valve.clone
    new_state.traveled_valve << edge_valve
    new_state.history = @history.clone
    new_state.history << edge_valve
    new_state
  end

  def open_valve_names
    @open_valves.map(&:name).sort.join(",")
  end

  def remaining_valves
    @map.valves.values - @open_valves
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
    #todo track total best case scenario, and if opening ALL the remaining valves
    # can't beat the current best case, just bail out.
    # best case rate = total flow + (rate + remaining valves rate) * remaining_time``
    if self.time_elapsed == MAX_TIME
      puts "REACHED END" if PRINT_ENABLED
      print_state
      if @@best_route.nil? || self.total_flow_rate > @@best_route.total_flow_rate
        @@best_route = self
      end
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
    remaining = remaining_valves
    if !@@best_route.nil?
      max_flow = remaining.map(&:flow).reduce(&:+)
      max_delta = (best_state.total_flow_rate + max_flow) * remaining_time
      return best_state if best_state.total_flow_amount + max_delta < @@best_route.total_flow_amount
    end
    if remaining_valves.empty?
      best_state.total_flow_amount += best_state.total_flow_rate * remaining_time
    else
      available = avail_edges
      if available.empty?
        best_state.total_flow_amount += best_state.total_flow_rate * remaining_time
      else
        available.each {|edge|
          if @current_valve.name == "AA"
            puts "check A" if PRINT_ENABLED
          end
          e = edge[:valve]
          puts "from #{@current_valve.name} travel edge #{e.name}" if PRINT_ENABLED
          new_map = travel_edge(edge)
          new_state = new_map.spider
          puts "spider state:" if PRINT_ENABLED
          new_state.print_state
          if new_state.total_flow_amount > best_state.total_flow_amount
            puts "NEW BEST STATE" if PRINT_ENABLED
            new_state.print_state
            best_state = new_state
          end
        }
      end
    end

    memoize(best_state, best_state.total_flow_amount - @total_flow_amount)
    if @@best_route.nil? || self.total_flow_rate > @@best_route.total_flow_rate
      @@best_route = self
    end
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
  valve = @map.add_valve(name, flow, edges)
  first_valve = valve if first_valve.nil?
end

@map.coalesce_zero_edges
puts @map

initial_state = TravelState.new(first_valve, @map)

answer = initial_state.spider

#todo uhhhhhhh what did I mess up here, I'm getting 702 vs 705 on the 20 step with bail outs

puts("FINAL ANSWER hits: #{TravelState.cache_hits} misses: #{TravelState.cache_misses}")
answer.print_state(true )