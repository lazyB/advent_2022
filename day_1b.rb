f = File.open("day_1.input")
def insert_elf(top_elves, elf, num_elves)
  result = []
  top_elves.each do |top_elf|
    if elf && elf > top_elf
      result << elf
      elf = nil
    end
    result << top_elf
  end
  result << elf if elf
  result.take(num_elves)
end

num_elves = 3
top_elves = []
current_elf = 0
while !f.eof? && line = f.readline do
  puts line
  if line == "\n"
    puts "break! current elf: #{current_elf} top elf: #{top_elves}"
    top_elves = insert_elf(top_elves, current_elf, num_elves)
    current_elf = 0
  else
    num = line.to_i
    current_elf += num
  end
end
puts "top elf: #{top_elves}"

puts top_elves.reduce(0, :+)