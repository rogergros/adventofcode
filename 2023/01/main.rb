def replace_string_numbers(line)
    equivalence = {
        # Two number name overlaps
        'oneight' => '18',
        'twone' => '21',
        'threeight' => '38',
        'fiveight' => '58',
        'sevenine' => '79',
        'eightwo' => '82',
        'eighthree' => '83',
        'nineight' => '98',
        # Number name
        'one' => '1',
        'two' => '2',
        'three' => '3',
        'four' => '4',
        'five' => '5',
        'six' => '6',
        'seven' => '7',
        'eight' => '8',
        'nine' => '9',
    }

    line.gsub(/#{equivalence.keys.join('|')}/, equivalence)
end

def calibration_value(line)
    line = replace_string_numbers(line)
    first_number = nil
    last_number = nil
    line.each_char do |char|
        if char >= '0' && char <= '9'
            if(first_number == nil)
                first_number = char
                last_number = char
            else
                last_number = char
            end
        end
    end
    return (first_number + last_number).to_i
end

# Ask for the filename
print "Enter the filename (default is 'input.txt'): "
input_filename = gets.chomp
input_filename = 'input.txt' if input_filename.empty?

# Reading the file
file = File.open(input_filename, "r")
file_content = file.read
file.close

# Calculating document calibration
total = 0
lines = file_content.split("\n")
lines.each do |line|
    total += calibration_value(line)
end
puts "Document calibration: #{total}"