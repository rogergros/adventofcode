require 'optparse'

HAND_TYPES = {
    :FIVE_OF_KIND => {
        :name => 'Five of a kind',
        :value => 7
    },
    :FOUR_OF_KIND => {
        :name => 'Four of a kind',
        :value => 6
    },
    :FULL_HOUSE => {
        :name => 'Full house',
        :value => 5
    },
    :THREE_OF_KIND => {
        :name => 'Three of a kind',
        :value => 4
    },
    :TWO_PAIRS => {
        :name => 'Two pairs',
        :value => 3
    },
    :ONE_PAIR => {
        :name => 'One pair',
        :value => 2
    },
    :HIGH_CARD => {
        :name => 'High card',
        :value => 1
    }
}

CARD_VALUES = {
    '2' => 'A',
    '3' => 'B',
    '4' => 'C',
    '5' => 'D',
    '6' => 'E',
    '7' => 'F',
    '8' => 'G',
    '9' => 'H',
    'T' => 'I',
    'J' => 'J',
    'Q' => 'K',
    'K' => 'L',
    'A' => 'M'
}

def parse_hands_bids(lines)
  lines.map do |line|
    hand, bid = line.split(' ')
    type = find_type(hand)
    {
        hand: hand,
        bid: bid.to_i,
        hand_type: type[:name],
        hand_value: type[:value],
        comparison_value: hand.chars.map{ |card| CARD_VALUES[card] }.map(&:to_s).join
    }
  end
end

def find_type(hand)
    amount_per_chart = hand.chars.group_by(&:itself).transform_values(&:count)
    amounts = amount_per_chart.values.sort.reverse
    if amounts.length == 1
        HAND_TYPES[:FIVE_OF_KIND]
    elsif amounts.length == 2 && amounts.include?(4)
        HAND_TYPES[:FOUR_OF_KIND]
    elsif amounts.length == 2 && amounts.include?(3)
        HAND_TYPES[:FULL_HOUSE]
    elsif amounts.length == 3 && amounts.include?(3)
        HAND_TYPES[:THREE_OF_KIND]
    elsif amounts.length == 3 && amounts.include?(2)
        HAND_TYPES[:TWO_PAIRS]
    elsif amounts.length == 4
        HAND_TYPES[:ONE_PAIR]
    else
        HAND_TYPES[:HIGH_CARD]
    end
end

def sort_hands(hands_bids)
    # Group bids by hand value
    grouped_bids = hands_bids.group_by { |hand_bid| hand_bid[:hand_value] }

    # Sort bids within each group by comparison value
    sorted_within_groups = grouped_bids.transform_values do |group|
        group.sort_by { |hand_bid| hand_bid[:comparison_value] }
    end

    # Sort groups by hand value
    sorted_groups = sorted_within_groups.sort_by { |hand_value, _| hand_value }

    # Flatten the groups into a single array
    sorted_groups.map { |_, group| group }.flatten
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
hands_bids = parse_hands_bids(lines)

print "Bids:\n"
hands_bids.each{ |hand_bid| print "#{hand_bid}\n" }

print "\nSorting hands...\n"
sorted_hands = sort_hands(hands_bids)
sorted_hands.each{ |hand_bid| print "Hand: #{hand_bid[:hand]}, Bid: #{hand_bid[:bid]}\n" }

total_winnings = sorted_hands.each_with_index.reduce(0) { |total, (hand_bid, i)| total + (hand_bid[:bid] * (i + 1))}
print "\nTotal Winnings: #{total_winnings}\n"