def detect_numbers_symbols(lines)
    numbers = []
    symbols = []

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
                symbols.push([line_index, char_index]) unless char == '.'
            end
            if char_index == line.length - 1 && current_number
                numbers.push(current_number)
                current_number = nil
            end
        end
    end

    [numbers, symbols]
end

def symbol_in_number_area(number, symbols, area)
    symbols.each do |symbol|
        if symbol[0] >= number['start'][0] - area && symbol[0] <= number['end'][0] + area
            if symbol[1] >= number['start'][1] - area && symbol[1] <= number['end'][1] + area
                return true
            end
        end
    end
    return false
end

# Ask for the filename
print "Enter the input file (default is 'input.txt'): "
input_filename = gets.chomp
input_filename = 'input.txt' if input_filename.empty?

# Reading the file
file = File.open(input_filename, "r")
file_content = file.read
file.close

# Detect numbers and symbols
lines = file_content.split("\n")
numbers, symbols = detect_numbers_symbols(lines)

# Sum numbers that are in symbols area 1
sum = 0
numbers.each do |number|
    sum += number['value'].to_i if symbol_in_number_area(number, symbols, 1)
end

puts "The sum of the correct lines is: #{sum}"