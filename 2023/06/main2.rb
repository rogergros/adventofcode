require 'optparse'

def find_winning_time_range(race, verbose)
    print "\nStarting to compute winning range for race #{race[:number]}\n" if verbose
    winning_range_candidate = 1..race[:time] - 1
    while calculate_distance(winning_range_candidate.first, race[:time]) <= race[:record]
        print "Increasing range start from #{winning_range_candidate.first} to #{winning_range_candidate.first + 1}\n" if verbose
        winning_range_candidate = winning_range_candidate.first + 1..winning_range_candidate.last
    end
    while calculate_distance(winning_range_candidate.last, race[:time]) <= race[:record]
        print "Decreasing range end from #{winning_range_candidate.last} to #{winning_range_candidate.last - 1}\n" if verbose
        winning_range_candidate = winning_range_candidate.first..winning_range_candidate.last - 1
    end
    winning_range_candidate
end

def calculate_distance(time_pressed, race_time)
    speed = time_pressed
    distance = (race_time - time_pressed) * speed
end

def parse_race(lines)
    _, times_string = lines[0].split(':')
    _, distances_string = lines[1].split(':')
    time = times_string.gsub(' ', '').to_i
    distance = distances_string.gsub(' ', '').to_i

    { time: time, record: distance }
end

verbose = false
OptionParser.new do |opts|
  opts.on('--verbose', 'Run verbosely') do |v|
    verbose = v
  end
end.parse!


# Ask for the filename
print "Enter the input file (default is 'input.txt'): "
input_filename = gets.chomp
input_filename = 'input.txt' if input_filename.empty?

# Reading the file
file = File.open(input_filename, "r")
file_content = file.read
file.close

lines = file_content.split("\n")
race = parse_race(lines)

print "Race:\n"
print "#{race}\n"

print "\nStarting to compute winning range:\n"
winning_range = find_winning_time_range(race, verbose)
print "Winning range for race #{race[:number]} is: #{winning_range}\n"

print "\nThe number of possible ways to win is #{winning_range.size}\n"
