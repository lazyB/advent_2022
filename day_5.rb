f = File.open('day_5.input')

stacks = (1..9).reduce({}) {|stacks, i| stacks[i] = []; stacks}
8.times do
  line = f.readline
  9.times do |i|
    input = line.slice(i*4, 4)
    input.strip! unless input.nil?
    if input.nil? || input.empty?
      next
    else
      puts "stack #{i}:" <<  input[1]
      stacks[i + 1].insert(0, input[1])
    end
  end
  9.times {|i| puts "#{i + 1} #{stacks[i+ 1]}"}
end

2.times {f.readline }

while !f.eof? && line = f.readline do
  tokens = line.split
  count = tokens[1].to_i
  source = tokens[3].to_i
  dest = tokens[5].to_i
  source_stack = stacks[source]
  dest_stack = stacks[dest]
  if count > source_stack.size
    puts "wut?"
  end
  dest_stack << source_stack.slice!(source_stack.size - count, count)
  dest_stack.flatten!
end


(1..9).each {|i|
  puts stacks[i].last
}