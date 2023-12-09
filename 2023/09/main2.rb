require 'optparse'

class History
    attr_reader :initial_sequence

    def initialize(line)
        @initial_sequence = Sequence.new(line.split(' ').map(&:to_i))
    end

    def resolve(verbose)
        sequences = [@initial_sequence]
        step = 0
        while !sequences.last.last_step?
            step += 1
            sequences << sequences.last.next_step
            print "Next step: #{sequences.last.values}\n" if verbose
        end
        
        step = sequences.length - 1
        first_difference = sequences.last.values.last
        while step > 0
            print "First difference in level #{step}: #{first_difference}\n" if verbose
            step -= 1
            first_difference = sequences[step].values.first - first_difference
        end
        first_difference
    end
end

class Sequence
    attr_reader :values

    def initialize(sequence)
        @values = sequence
    end

    def next_step
        @next_step ||= begin
            next_step = []
            (0..@values.length - 2).each do |index|
                next_step << @values[index + 1] - @values[index]
            end
            Sequence.new(next_step)
        end
    end

    def last_step?
        @values.uniq.length == 1
    end
end

# Main script body

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
histories = lines.map { |line| History.new(line) }

sum = 0
histories.each do |history|
    print "History: #{history.initial_sequence.values}\n"
    solution = history.resolve(verbose)
    print "Resolution: #{solution}\n"
    sum += solution
end

print "Puzzle solution is: #{sum}\n"