def detect_numbers_gears(lines)
    numbers = []
    gears = []

    current_number = nil
    lines.each_with_index do |line, line_index|
        line.each_char.with_index do |char, char_index|
            if char >= '0' && char <= '9'
                if current_number.nil?
                    current_number = {
                        'value' => char,
                        'start' => [line_index, char_index],
                        'end' => [line_index, char_index]
                    }
                else
                    current_number['value'] += char
                    current_number['end'] = [line_index, char_index]
                end
            else
                if current_number
                    numbers.push(current_number)
                    current_number = nil
                end
                gears.push([line_index, char_index]) if char == '*'
            end
            if char_index == line.length - 1 && current_number
                numbers.push(current_number)
                current_number = nil
            end
        end
    end

    [numbers, gears]
end

def adjacent_pairs_multiplied(gear, numbers)
    adjacent_numbers = []
    numbers.each do |number|
        if gear[0] >= number['start'][0] - 1 && gear[0] <= number['end'][0] + 1
            if gear[1] >= number['start'][1] - 1 && gear[1] <= number['end'][1] + 1
                if adjacent_numbers.length == 2
                    return 0
                else
                    adjacent_numbers.push(number)
                end
            end
        end
    end

    if adjacent_numbers.length == 2
        print "Gear #{gear} has a pair of numbers (#{adjacent_numbers[0]['value']} & #{adjacent_numbers[1]['value']})\n"
        return adjacent_numbers[0]['value'].to_i * adjacent_numbers[1]['value'].to_i
    end
    return 0
end

# Ask for the filename
print "Enter the input file (default is 'input.txt'): "
input_filename = gets.chomp
input_filename = 'input.txt' if input_filename.empty?

# Reading the file
file = File.open(input_filename, "r")
file_content = file.read
file.close

# Detect numbers and gears
lines = file_content.split("\n")
numbers, gears = detect_numbers_gears(lines)

sum = 0
gears.each do |gear|
    sum += adjacent_pairs_multiplied(gear, numbers)
end

print "\nThe sum of the pairs of gear adjacent numbers is: #{sum}\n"