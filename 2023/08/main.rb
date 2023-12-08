require 'optparse'

class Node
    attr_reader :id, :next_step_left, :next_step_right

    def initialize(line)
        @id, next_step = line.split('=').map(&:strip)
        @next_step_left = next_step[1..3]
        @next_step_right = next_step[6..8]
    end

    def next_node(step)
        if step == 'L'
            @next_step_left
        else
            @next_step_right
        end
    end
end

class Network
    attr_reader :nodes

    def initialize(lines)
        @nodes = lines.each_with_object({}) do |line, nodes|
            node = Node.new(line)
            nodes[node.id] = node
        end
    end

    def resolve(instructions, verbose)
        steps = 0
        current_node = @nodes['AAA']
        while current_node.id != 'ZZZ'
            print "STEP #{steps}\n" if verbose
            steps += 1
            next_step = instructions.next_step
            print "Current node: #{current_node.id} Next step: #{next_step}\n" if verbose
            current_node = @nodes[current_node.next_node(next_step)]
            print "Next node: #{current_node.id}\n" if verbose
        end
        steps
    end
end

class Instructions
    attr_reader :steps

    def initialize(line)
        @steps = line
        @current_step = 0
    end

    def next_step
        if @current_step == @steps.length - 1
            @current_step = 0
        else
            @current_step += 1
        end
        @steps[@current_step - 1]
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
instructions = Instructions.new(lines.shift)
lines.shift # Discard the empty line
network = Network.new(lines)

steps = network.resolve(instructions, verbose)

print "Number of steps to resolve is: #{steps}\n"