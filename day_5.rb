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