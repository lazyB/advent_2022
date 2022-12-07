f = File.open("day_3.input")

priorities = ('a'..'z').reduce({}) {|scores, c| puts scores; puts c; scores[c] = scores.size + 1; scores}
priorities = ('A'..'Z').reduce(priorities) {|scores, c| puts scores; puts c; scores[c] = scores.size + 1; scores}

score = 0
while !f.eof? && line = f.readline do
  dups = Set.new
  line.each_char do |c|
    dups << c
  end
  line = f.readline
  second_dups = Set.new
  line.each_char { |c|
    if dups.include?(c)
      second_dups << c
    end
}
  line = f.readline
  line.each_char {|c|
    if second_dups.include?(c)
      score += priorities[c]
      break
    end
}

end
puts score
