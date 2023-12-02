
CUBES = {
    'red' => 12,
    'green' => 13,
    'blue' => 14,
}


def minimum_dices(line)
    cubes = {
        'red' => 0,
        'green' => 0,
        'blue' => 0,
    }
    game, sets = line.split(':')
    sets = sets.split(';')
    sets.each do |set|
        dices = set.split(',')
        dices.each do |dice|
            number, color = dice.strip.split(' ')
            cubes[color] = number.to_i if(number.to_i > cubes[color])
        end
    end

    return cubes.values.reduce(1, :*)
end

# Ask for the filename
print "Enter number of RED cubes  (default is '12'): "
red_dices = gets.chomp
CUBES['red'] = gets.chomp unless red_dices.empty?
print "Enter number of GREEN cubes  (default is '13'): "
green_dices = gets.chomp
CUBES['green'] = gets.chomp unless green_dices.empty?
print "Enter number of BLUE cubes  (default is '14'): "
blue_dices = gets.chomp
CUBES['blue'] = gets.chomp unless blue_dices.empty?

print "Enter the input file (default is 'input.txt'): "
input_filename = gets.chomp
input_filename = 'input.txt' if input_filename.empty?

# Reading the file
file = File.open(input_filename, "r")
file_content = file.read
file.close

# Calculating the sum of all lines power for the minimum dices
lines = file_content.split("\n")
sum = 0
lines.each_with_index do |line, index|
    sum += minimum_dices(line)
end

puts "The sum of the minimum dices power is: #{sum}"