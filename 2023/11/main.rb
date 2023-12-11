require 'optparse'

class Coordinates
    attr_reader :x, :y

    def initialize(x, y)
        @x = x
        @y = y
    end

    def line
        @y
    end

    def column
        @x
    end

    def to_s
        "(#{@x}, #{@y})"
    end
end

class SkyMap
    attr_reader :map, :galaxies

    def initialize(lines)
        @galaxies = []
        @max_x = lines.first.length - 1
        @max_y = lines.length - 1
        lines.each_with_index do |line, y|
            line.chars.each_with_index do |char, x|
                if char == "#"
                    @galaxies << Coordinates.new(x, y)
                end
            end
        end
    end

    def is_galaxy?(x, y)
        @galaxies_coordinates ||= begin
            galaxies_coordinates = {}
            @galaxies.each do |galaxy|
                galaxies_coordinates[galaxy.line] ||= {}
                galaxies_coordinates[galaxy.line][galaxy.column] = true
            end
            galaxies_coordinates
        end

        @galaxies_coordinates.dig(y, x) == true
    end

    def expand(expand_ratio, verbose)
        no_galaxy_lines = (0..@max_y).to_a - @galaxies.map { |galaxy| galaxy.line }
        no_galaxy_columns = (0..@max_x).to_a - @galaxies.map { |galaxy| galaxy.column }

        print "No galaxy lines: #{no_galaxy_lines}\n" if verbose
        print "No galaxy columns: #{no_galaxy_columns}\n" if verbose

        @max_y = @max_y + (no_galaxy_lines.length * (expand_ratio - 1))
        @max_x = @max_x + (no_galaxy_columns.length * (expand_ratio - 1))

        @galaxies = @galaxies.map do |galaxy|
            Coordinates.new(
                galaxy.column + (no_galaxy_columns.select{ |x| x < galaxy.column }.length * (expand_ratio - 1)),
                galaxy.line + (no_galaxy_lines.select{ |y| y < galaxy.line }.length * (expand_ratio - 1))
            )
        end

        # Remove memoized value
        @galaxies_coordinates = nil
    end

    def galaxies_distances(verbose)
        combinations = @galaxies.combination(2).to_a

        print "Combinations:\n" if verbose
        combinations.map do |combination|
            start = combination.first
            finish = combination.last
            distance = (start.x - finish.x).abs + (start.y - finish.y).abs
            print "#{combination.first} - #{combination.last} -> Distance: #{distance}\n" if verbose
            distance
        end
    end

    def draw
        (0..@max_y).each do |y|
            (0..@max_x).each do |x|
                print is_galaxy?(x, y) ? "#" : "."
            end
            print "\n"
        end
    end

    def draw_galaxies
        @galaxies = @galaxies.sort_by { |galaxy| [galaxy.line, galaxy.column] }.each { |galaxy| print "#{galaxy} " }
        print "\n"
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

print "Enter expand ratio (default is 2): "
expand_ratio = gets.chomp.to_i
expand_ratio = 2 if expand_ratio == 0

# Reading the file
file = File.open(input_filename, "r")
file_content = file.read
file.close

lines = file_content.split("\n")
skymap = SkyMap.new(lines)

print "Sky map:\n"
skymap.draw

print "\nGalaxies:\n" if verbose
print "#{skymap.draw_galaxies}\n" if verbose

print "\nExpanding...\n"
skymap.expand(expand_ratio, verbose)

print "Sky map:\n" if verbose
skymap.draw if verbose

print "\nGalaxies:\n" if verbose
print "#{skymap.draw_galaxies}\n" if verbose

print "Finding distances...\n"
distances = skymap.galaxies_distances(verbose)

print "Total distance: #{distances.reduce(:+)}\n"