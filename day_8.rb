
def check_hidden(i, j, grid)
  height = grid[i][j]
  # return false if height == 0
  puts "height #{height} i #{i} j #{j}"
  row = grid[i]
  col = (0...grid.length).map {|c_j| grid[c_j][j]}
  left = row.slice(0, j)
  right = row.slice((j + 1), (row.length - j))
  top = col.slice(0, i)
  bottom = col.slice(i + 1, col.length - i)
  invisible = lambda {|itm| itm >= height}
  left.any?(invisible) && right.any?(invisible) && top.any?(invisible) && bottom.any?(invisible)
end

def calculate_viz_score(i, j, grid)
  height = grid[i][j]
  row = grid[i]
  col = (0...grid.length).map {|c_j| grid[c_j][j]}
  left = row.slice(0, j)
  right = row.slice((j + 1), (row.length - j))
  top = col.slice(0, i)
  bottom = col.slice(i + 1, col.length - i)
  left_viz = viz_score(left.reverse, height)
  right_viz = viz_score(right, height)
  top_viz = viz_score(top.reverse, height)
  bottom_viz = viz_score(bottom, height)
  left_viz * right_viz * top_viz * bottom_viz
end

def viz_score(trees, height)
  trees.reduce(0) do |score, tree_height|
    score += 1
    if tree_height >= height
      return score
    end
    score
  end
end
grid = []
File.open("day_8.input").each_line do |line|
  row = []
  line.to_s.strip.each_char {|c| row << c.to_i}
  grid << row
end

grid_size = grid.length
max_viz = 0
#
(1...(grid_size-1)).each do |i|
  (1...(grid_size-1)).each do |j|
    viz = calculate_viz_score(i, j, grid)
    max_viz = viz if viz > max_viz
  end
end


puts max_viz