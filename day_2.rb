f = File.open("day_2.input")



def score_match(elf_play, outcome)
  elf_plays = {
    'A': 'ROCK',
    'B': 'PAPER',
    'C': 'SCISSORS'
  }

  my_plays = {
    'X': 'ROCK',
    'Y': 'PAPER',
    'Z': 'SCISSORS'
  }

  outcomes = {
    'X': 'LOSE',
    'Y': 'DRAW',
    'Z': 'WIN'
  }

  score = case outcome
          when 'X'
            0
          when 'Y'
            3
          when 'Z'
            6
          end
  my_play = case elf_play
            when 'A' # rock
              if outcome == 'X' #lose
                'Z'
              elsif outcome == 'Y' #draw
                'X'
              elsif outcome == 'Z' #win
                'Y'
              end
            when 'B' # paper
              if outcome == 'X' #lose
                'X'
              elsif outcome == 'Y' #draw
                'Y'
              elsif outcome == 'Z' #win
                'Z'
              end
            when 'C' # scissors
              if outcome == 'X' #lose
                'Y'
              elsif outcome == 'Y' #draw
                'Z'
              elsif outcome == 'Z' #win
                'X'
              end
            end
  puts "elf: #{elf_plays[elf_play.to_sym]} my_play:#{my_plays[my_play.to_sym]} outcome: #{outcomes[outcome.to_sym]}"

  score += case my_play
           when 'X'
             1
           when 'Y'
             2
           when 'Z'
             3
           end
end

score = 0
while !f.eof? && line = f.readline do
  plays = line.split
  puts plays
  score += score_match(*plays)
end
puts score
