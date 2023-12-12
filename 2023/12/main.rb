
class Springs

    def initialize(spring_line, conditions_line)
        @spring_line = spring_line
        @conditions_line = conditions_line.split(",").map(&:to_i)
    end

    def arrangements(verbose)
        valid_combinations(@spring_line, 0, verbose).length
    end

    def valid_combinations(springs_map, position, verbose)
        is_full_combination = position == springs_map.length

        if !is_full_combination && springs_map[position] != '?'
            return valid_combinations(springs_map, position + 1, verbose)
        end

        partial_springs_map = position == 0 ? '' : springs_map[0..position-1]
        partial_conditions = build_conditions(partial_springs_map)

        fit_conditions = !is_full_combination && fit_conditions(partial_conditions, @conditions_line) || partial_conditions == @conditions_line

        if is_full_combination && fit_conditions
            print "Map #{springs_map} with conditions #{partial_conditions} fully match, getting them\n" if verbose
            return [springs_map]
        elsif !fit_conditions
            return []
        end

        springs_map_with_spring = springs_map.dup
        springs_map_with_spring[position] = '.'

        springs_map_with_spring_bropen = springs_map.dup
        springs_map_with_spring_bropen[position] = '#'

        valid_combinations(springs_map_with_spring, position + 1, verbose) + valid_combinations(springs_map_with_spring_bropen, position + 1, verbose)
    end

    def fit_conditions(partial_conditions, conditions)
        return false if partial_conditions.length > conditions.length 
        partial_conditions.each_with_index do |partial_condition, index|
            if index == partial_conditions.length - 1
                return false if partial_condition > conditions[index]
            else
                return false if partial_condition != conditions[index]
            end
        end
        return true
    end

    def build_conditions(springs_map)
        conditions = []
        springs = 0
        springs_map.chars do |position|
            if position == '#'
                springs += 1
            elsif position == '.'
                conditions << springs if springs != 0
                springs = 0
            end
        end
        conditions << springs unless springs == 0
        conditions
    end


    def draw
        print "Spring line: #{@spring_line}\n"
        print "Conditions line: #{@conditions_line}\n"
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
print "Enter the input file (default is 'demo.txt'): "
input_filename = gets.chomp
input_filename = 'demo.txt' if input_filename.empty?

# Reading the file
file = File.open(input_filename, "r")
file_content = file.read
file.close

springs_lines = file_content.split("\n").map do |line|
    spring_line, conditions_line = line.split(" ")
    Springs.new(spring_line, conditions_line)
end

total_arrangements = springs_lines.reduce(0) do |acc, springs|
    print "\nSolving springs...\n"
    springs.draw
    arrangements = springs.arrangements(verbose)
    print "#{arrangements} possible arrangements\n\n"
    acc += arrangements
end

print "\nTotal arrangements: #{total_arrangements}\n"