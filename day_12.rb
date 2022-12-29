grid = []
y = 0
@start_x = nil
@start_y = nil
@goal_x = nil
@goal_y = nil
File.open("day_12.input").each_line do |line|
  x = 0
  row = []
  line.strip.each_char do |c|
    if c == 'S'
      @start_x = x
      @start_y = y
      row << 'a'
    elsif c == 'E'
      @goal_x = x
      @goal_y = y
      row << 'z'
    else
      row << c
    end
    x += 1
  end
  grid << row
  y += 1
end

@memo = {}
@traveled = {}

def avail_directions(grid, x, y)
  directions = []
  # puts "avail: #{x} #{y}"
  avail = []
  current_elev = grid[y][x].ord
  if(x >0)
    left = grid[y][x-1]
    unless left.ord - current_elev > 1
      directions << [x-1, y]
      avail << "left"
    end
  end
  if (x+1 < grid.first.length)
    right = grid[y][x+1]
    unless right.ord - current_elev > 1
      directions << [x+1, y]
      avail << "right"
    end
  end
  if y > 0
    top = grid[y-1][x]
    unless top.ord - current_elev > 1
      directions << [x, y-1]
      avail << "up"
    end
  end
  if y + 1 < grid.length
    bottom = grid[y+1][x]
    unless bottom.ord - current_elev > 1
      directions << [x, y+1]
      avail << "down"
    end
  end
  filtered = directions.reject{|xy| @traveled.include?("#{xy[0]},#{xy[1]}")}
  # puts "directions #{avail.join(",")}"
  filtered
end

def steps_to_goal(grid, x, y)
  tag = "#{x},#{y}"
  m = @memo[tag]
  return m unless m.nil?
 if x == @goal_x && y == @goal_y
   puts "GOAL"
   return 0
 end

  best_route = -1
  dirs = avail_directions(grid, x, y)
  unless dirs.empty?
    @traveled[tag] = true
    dirs.each do |xy|
      next_x, next_y = xy
      next_steps = steps_to_goal(grid, next_x, next_y)
      if next_steps >= 0 && (best_route.negative? || next_steps + 1 < best_route)
        puts "Best route #{x}, #{y} = #{next_x}, #{next_y} : #{next_steps + 1}"
        best_route = next_steps + 1
      end
    end
    @traveled[tag] = false
  end
  # @memo[tag] = best_route if best_route >= 0
  best_route
end
puts "start: #{@start_x} #{@start_y} goal: #{@goal_x} #{@goal_y}"
# steps = steps_to_goal(grid, 6, 2)
steps = steps_to_goal(grid, @start_x, @start_y)
puts "best steps #{steps}"