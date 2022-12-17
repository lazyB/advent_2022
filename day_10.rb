x = 1
step = 0
next_signal = 40
signal_sum = 0
crt = ''

def draw_pixel(step, x)
  r = (x-1)..(x+1)
  if r.include? step
    '#'
  else
     '-'
  end
end

crt << draw_pixel(step, x)
File.open('day_10.input').each_line do|line|
  op, value = line.split
  # puts "##{op} #{value}"
  case op
  when 'addx'
    step += 1
    crt << draw_pixel(step, x)
  when 'noop'
  end
  if step == next_signal
    # puts "LOG\n\nstep:#{step} #{x}\n\n-------"
    step = 0
    puts crt
    crt = ''
    # puts "sum #{signal_sum}"
  end
  step += 1
  x += value.to_i
  crt << draw_pixel(step, x)
  if step == next_signal
    # puts "LOG\n\nstep:#{step} #{x}\n\n-------"
    step = 0
    puts crt
    crt = ''
  end
end