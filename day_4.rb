f = File.open("day_4.input")

score = 0
while !f.eof? && line = f.readline do
  l1, l2, r1, r2 = line.split(',').map{|side| side.split('-')}.flatten.map(&:to_i)
  if (l2 >= r1 && l1 <= r2) || (r2 >= l1 && r1 <= l2)
    puts "overlap #{line}"
    score += 1
  else
    puts "no overlap #{line}"
  end
end
puts score