def print_grid(grid, min_x, max_x)
  puts ''
  grid.each do |line|
    sub_line = line.slice(min_x, max_x - min_x)
    sub_line.each {|c| putc c}
    puts ''
  end
  puts ''
end

grid = []
min_x = nil
max_y = nil
max_x = nil
paths = []
File.open("day_14.input").each_line do |line|
  tokens = line.split(' -> ')
  path = []
  tokens.each { |token|
    x, y = token.split(',').map(&:to_i)
    if min_x.nil? || x < min_x
      min_x = x
    end

    if max_x.nil? || x > max_x
      max_x = x
    end
    if max_y.nil? || y > max_y
      max_y = y
    end
    path << [x.to_i, y.to_i]
  }
  paths << path
end

grid = []
max_y += 2
(max_y + 1).times {|i|
  fill_char = '.'
  fill_char = '#' if i == max_y
  grid_line = Array.new(max_x * 3, fill_char)
  grid << grid_line
}




puts "#{min_x}/#{max_x}/#{max_y}"
print_grid(grid, min_x, max_x)

def draw_path(grid, path, min_x)
  last_node = nil
  path.each do |node|
    if last_node.nil?
      last_node = node
    else
      x, y = node
      last_x, last_y = last_node
      if x < last_x # going left
        (x..last_x).each {|i| grid[y][i] = '#' }
      elsif x > last_x # going right
        (last_x..x).each {|i| grid[y][i] = '#'}
      elsif y < last_y # going up
        (y..last_y).each {|i| grid[i][x] = '#'}
      else
        (last_y..y).each {|i| grid[i][x] = '#'}
      end
      last_node = node
      # print_grid(grid, min_x)
    end
  end
end

paths.each {|path| draw_path(grid, path, min_x)}

has_room = true

def next_sand_pos(x, y, grid)
  return [0,0] if x > grid[0].length - 1
  return [0,0] if y > grid.length - 2
  if(grid[y + 1][x] == '.') #drop down
    [x, y+1]
  elsif (grid[y+1][x - 1] == '.') # down-left
    [x - 1, y + 1]
  elsif grid[y+1][x + 1] == '.' # down-right
    [x + 1, y + 1]
  else # no more moves
    [x, y]
  end
end
count = 0
while has_room do
  sand_pos = [500, 0]
  count += 1
  sand_x, sand_y = sand_pos
  next_x, next_y = next_sand_pos(sand_x, sand_y, grid)
  while !(next_x == sand_x && next_y == sand_y)
    sand_x = next_x
    sand_y = next_y
    next_x, next_y = next_sand_pos(sand_x, sand_y, grid)
  end
  has_room = grid[sand_y][sand_x] != '*'
  grid[sand_y][sand_x] = '*'
  min_x = sand_x if(sand_x < min_x)
  max_x = sand_x if(sand_x > max_x)
  print_grid(grid, min_x, max_x) if count % 100 == 0

  # has_room = sand_x <= max_x && sand_x >= min_x && sand_y < max_y
  puts "count #{count}"
  puts "finished" unless has_room
end

print_grid(grid, min_x, max_x)
puts "finished : #{count}"