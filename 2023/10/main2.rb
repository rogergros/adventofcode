require 'optparse'

READABLE_SYMBOLS = {
    "|" => "│",
    "-" => "─",
    "L" => "└",
    "J" => "┘",
    "7" => "┐",
    "F" => "┌",
    "." => " ",
    "S" => "✪",
}

DIRECTION_SYMBOLS = {
    up: "↑",
    down: "↓",
    left: "←",
    right: "→",
}

class Map
    attr_reader :map

    def initialize(lines)
        @map = lines.map.with_index do |line, y|
            line.chars.map.with_index do |char, x|
                @start = [y, x] if char == "✪"
                {
                    tile: Tile.new(char),
                    path: nil,
                    enclosed: false,
                    up_down: nil,
                }
            end
        end
    end

    def starting_direction
        return :left if(@map[@start[0]][@start[1]-1]) && (@map[@start[0]][@start[1]-1][:tile].connections.include?(:right))
        return :right if(@map[@start[0]][@start[1]+1]) && (@map[@start[0]][@start[1]+1][:tile].connections.include?(:left))
        return :up if(@map[@start[0]-1][@start[1]]) && (@map[@start[0]-1][@start[1]][:tile].connections.include?(:down))
        return :down if(@map[@start[0]+1][@start[1]]) && (@map[@start[0]+1][@start[1]][:tile].connections.include?(:up))
    end
    
    def next_coordinates(coordinates, direction)
        case direction
        when :up
            return [coordinates[0]-1, coordinates[1]]
        when :down
            return [coordinates[0]+1, coordinates[1]]
        when :left
            return [coordinates[0], coordinates[1]-1]
        when :right
            return [coordinates[0], coordinates[1]+1]
        else
            raise "Unknown direction: #{direction}"
        end
    end

    def resolve(verbose)
        current_coordinates = @start
        direction = starting_direction

        loop do
            @map[current_coordinates[0]][current_coordinates[1]][:path] = direction
            current_coordinates = next_coordinates(current_coordinates, direction)
            tile = @map[current_coordinates[0]][current_coordinates[1]][:tile]
            next_direction = tile.next_direction(direction)

            break if tile.starting_point?

            direction = next_direction
        end

        total_enclosed = 0
        @map.each_with_index do |line, y|
            up_or_down = nil
            total_winding = 0
            line.each_with_index do |tile, x|
                print "-> Line #{y} column #{x} up_and_down #{up_or_down} path #{tile[:path]} char #{tile[:tile].char} \n" if verbose
                if up_or_down != :up && (tile[:path] == :up || ( tile[:path] == :right && ['┌','┘'].include?(tile[:tile].char) || ( tile[:path] == :left && ['└','┐'].include?(tile[:tile].char))))
                    print "Line #{y} column #{x} up_and_down #{up_or_down} path #{tile[:path]} char #{tile[:tile].char}: UP \n" if verbose
                    total_winding += 1
                    tile[:up_and_down] = :up
                    up_or_down = :up
                elsif up_or_down != :down && (tile[:path] == :down || ( tile[:path] == :left && ['┌','┘'].include?(tile[:tile].char) || ( tile[:path] == :right && ['└','┐'].include?(tile[:tile].char))))
                    print "Line #{y} column #{x} up_and_down #{up_or_down} path #{tile[:path]} char #{tile[:tile].char}: DOWN \n" if verbose
                    total_winding -= 1
                    tile[:up_and_down] = :down
                    up_or_down = :down
                elsif !tile[:path] 
                    up_or_down = nil
                    if total_winding != 0
                        print "Line #{y} column #{x} up_and_down #{up_or_down} path #{tile[:path]} char #{tile[:tile].char}: ENDORSED \n" if verbose
                        total_enclosed += 1
                        tile[:enclosed] = true
                    end
                end
            end
        end

        total_enclosed
    end

    def show
        @map.each do |line|
            line.each do |tile|
                if tile[:path]
                    print "\e[31m#{tile[:tile].char}\e[0m"
                elsif tile[:enclosed]
                    char = tile[:tile].char == ' ' ? '.' : tile[:tile].char
                    print "\e[32m#{char}\e[0m"
                else
                    print "#{tile[:tile].char}"
                end
            end
            print "\n"
        end
    end

    def show_directions
        @map.each do |line|
            line.each do |tile|
                if tile[:path]
                    char = DIRECTION_SYMBOLS[tile[:path]]
                    print "\e[31m#{char}\e[0m"
                elsif tile[:enclosed]
                    char = tile[:tile].char == ' ' ? '.' : tile[:tile].char
                    print "\e[32m#{char}\e[0m"
                else
                    print "#{tile[:tile].char}"
                end
            end
            print "\n"
        end
    end

    def show_up_and_down
        @map.each do |line|
            line.each do |tile|
                if tile[:up_and_down]
                    char = DIRECTION_SYMBOLS[tile[:up_and_down]]
                    print "\e[31m#{char}\e[0m"
                elsif tile[:enclosed]
                    char = tile[:tile].char == ' ' ? '.' : tile[:tile].char
                    print "\e[32m#{char}\e[0m"
                else
                    print "#{tile[:tile].char}"
                end
            end
            print "\n"
        end
    end
end

class Tile
    attr_reader :char

    def initialize(char)
        @char = char
    end

    def connections
        case @char
        when "│"
            return [:up, :down]
        when "─"
            return [:left, :right]
        when "└"
            return [:up, :right]
        when "┘"
            return [:up, :left]
        when "┐"
            return [:down, :left]
        when "┌"
            return [:down, :right]
        when "┌"
            return [:down, :right]
        when " "
            return []
        when "✪"
            return [:up, :down, :left, :right]
        else
            raise "Unknown tile: '#{@char}'"
        end
    end

    def next_direction(previous_direction)
        opposite_connections = { up: :down, down: :up, left: :right, right: :left }
        previous_connection = opposite_connections[previous_direction]
        connections.each do |connection|
            return connection if connection != previous_connection
        end
    end

    def starting_point?
        @char == "✪"
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

lines = file_content.gsub(/./) { |char| READABLE_SYMBOLS[char] || char }.split("\n")
map = Map.new(lines)

print "Readable map:\n"
map.show

print "\nStarting title: #{map.starting_direction}\n"
print "\nResolving map...\n"
amount_enclosed = map.resolve(verbose)
print "Resolved map:\n"
map.show
print "\n" if verbose
map.show_directions if verbose
print "\n" if verbose
map.show_up_and_down if verbose

print "Amount enclosed is: #{amount_enclosed}\n"