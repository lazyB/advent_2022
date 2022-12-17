def is_adj?(head, tail)
  delta_x = (head[0] - tail[0]).abs
  delta_y = (head[1] - tail[1]).abs
  delta_x <= 1 && delta_y <= 1
end

def move_head(direction, head)
  case direction
  when 'L'
    head[0] = head[0] - 1
  when 'R'
    head[0] = head[0] + 1
  when 'U'
    head[1] = head[1] + 1
  when 'D'
    head[1] = head[1] - 1
  end
  head
end

def follow_tail(head, tail)
  return tail if is_adj?(head, tail)
  if(head[1] == tail[1]) # same x value, move up/down
    move_head(head[0] < tail[0] ? 'L' : 'R', tail)
  elsif(head[0] == tail[0]) # same y value, move l/r
    move_head(head[1] > tail[1] ? 'U' : 'D', tail)
  else # diagonal walk
    move_head(head[0] < tail[0] ? 'L' : 'R', tail)
    move_head(head[1] > tail[1] ? 'U' : 'D', tail)
  end
end
num_knots = 10
positions = Set.new
knots = []
num_knots.times {
  knots << [0, 0]
}
File.open("day_9.input").each_line do |line|
  direction, steps = line.split
  num_steps = steps.to_i
  num_steps.times {
    num_knots.times {|i|
      if i.zero?
        knots[i] = move_head(direction, knots[i])
      else
        knots[i] = follow_tail(knots[i - 1], knots[i])
        raise "uh oh" if !is_adj?(knots[i - 1], knots[i])
        if i == num_knots - 1
          positions.add("#{knots[i][0]},#{knots[i][1]}")
        end
      end

    }
  }
end

puts positions.size