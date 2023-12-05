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
            'amount_winning_numbers' => card_winning_numbers.length,
            'copies' => 1
        }
    end
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

total_scratchboards = 0
cards.each_with_index do |card, index|
    if card['amount_winning_numbers'] > 0
        for i in (index + 1)..(index + card['amount_winning_numbers'])
            cards[i]['copies'] += card['copies']
        end
    end
    total_scratchboards += card['copies']
end

puts "The number of total scratchboards is: #{total_scratchboards}"
