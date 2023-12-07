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
    'J' => 'A',
    '2' => 'B',
    '3' => 'C',
    '4' => 'D',
    '5' => 'E',
    '6' => 'F',
    '7' => 'G',
    '8' => 'H',
    '9' => 'I',
    'T' => 'J',
    'Q' => 'K',
    'K' => 'L',
    'A' => 'M'
}

def parse_hands_bids(lines, verbose)
  lines.map do |line|
    hand, bid = line.split(' ')
    type = find_type(hand, verbose)
    {
        hand: hand,
        bid: bid.to_i,
        hand_type: type[:name],
        hand_value: type[:value],
        comparison_value: hand.chars.map{ |card| CARD_VALUES[card] }.map(&:to_s).join
    }
  end
end

def find_type(hand, verbose)
    print "Hand: #{hand}\n" if verbose
    jokers = hand.count('J')
    hand = hand.gsub('J', '')
    print "Jokers: #{jokers}\n" if verbose
    card_groups = hand.chars.group_by(&:itself).transform_values(&:count).values.sort.reverse
    print "Card groups: #{card_groups}\n" if verbose
    if(jokers && card_groups.length > 0)
        card_groups[0] += jokers
    elsif(jokers)
        card_groups = [jokers]
    end
    print "Card groups with joker: #{card_groups}\n" if verbose
    case card_groups
    when [5]
        return HAND_TYPES[:FIVE_OF_KIND]
    when [4, 1]
        return HAND_TYPES[:FOUR_OF_KIND]
    when [3, 2]
        return HAND_TYPES[:FULL_HOUSE]
    when [3, 1, 1]
        return HAND_TYPES[:THREE_OF_KIND]
    when [2, 2, 1]
        return HAND_TYPES[:TWO_PAIRS]
    when [2, 1, 1, 1]
        return HAND_TYPES[:ONE_PAIR]
    else
        return HAND_TYPES[:HIGH_CARD]
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
hands_bids = parse_hands_bids(lines, verbose)

print "Bids:\n"
hands_bids.each{ |hand_bid| print "#{hand_bid}\n" }

print "\nSorting hands...\n"
sorted_hands = sort_hands(hands_bids)
sorted_hands.each{ |hand_bid| print "Hand: #{hand_bid[:hand]}, Bid: #{hand_bid[:bid]}, Type: #{hand_bid[:hand_type]}\n" }

total_winnings = sorted_hands.each_with_index.reduce(0) { |total, (hand_bid, i)| total + (hand_bid[:bid] * (i + 1))}
print "\nTotal Winnings: #{total_winnings}\n"