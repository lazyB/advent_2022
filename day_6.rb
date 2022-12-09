f = File.open('day_6.input')

buffer = []
idx = 0
f.each_char do |c|
  buffer << c
  if buffer.count > 14
    buffer.delete_at(0)
  end
  idx += 1
  s = Set.new(buffer)
  if s.count == 14
    break
  end
end

puts idx