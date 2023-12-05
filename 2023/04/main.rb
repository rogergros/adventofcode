def process_cards_info(lines)
    lines.map do |line|
        title, numbers = line.split(':')
        winning_numbers, card_numbers = numbers.gsub!(/\s+/, ' ').split('|')
        winning_numbers = winning_numbers.split(' ').map(&:to_i).sort
        card_numbers = card_numbers.split(' ').map(&:to_i).sort
        card_winning_numbers = winning_numbers & card_numbers
    
        {
            'title' => title,
            'winning_numbers' => winning_numbers,
            'card_numbers' => card_numbers,
            'card_winning_numbers' => card_winning_numbers,
            'points' => calculate_card_points(card_winning_numbers)
        }
    end
end

def calculate_card_points(card_winning_numbers)
    matches = card_winning_numbers.length
    return 0 if matches == 0
    return 1 if matches == 1
    2 ** (matches - 1)
end

# Ask for the filename
print "Enter the input file (default is 'input.txt'): "
input_filename = gets.chomp
input_filename = 'input.txt' if input_filename.empty?

# Reading the file
file = File.open(input_filename, "r")
file_content = file.read
file.close

# Get lines and detect winning numbers and card numbers
lines = file_content.split("\n")
cards = process_cards_info(lines)
points = cards.map { |card| card['points'] }.sum

puts "The number of total points is: #{points}"
