f = File.open("day_1.input")

top_elf = -1
current_elf = 0
while !f.eof? && line = f.readline do
  puts line
  if line == "\n"
    puts "break! current elf: #{current_elf} top elf: #{top_elf}"
    if top_elf < current_elf
      top_elf = current_elf
    end
    current_elf = 0
  else
    num = line.to_i
    current_elf += num
  end
end
puts "top elf: #{top_elf}"
