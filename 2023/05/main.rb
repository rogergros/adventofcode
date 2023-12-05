def parse_seeds(seeds_line)
    _, seeds = seeds_line.split(':')
    seeds.split(' ').map(&:to_i)
end

def parse_mapping_maps(lines)
    maps = []
    current_map = {}
    lines.each do |line|
        if line.empty?
            next
        elsif line.include?('map:')
            maps << current_map if current_map.any?
            current_map = {
                name: line.split(' ').first,
                correspondences: []
            }
        else
            dest_start_range, src_start_range, range_length = line.split(' ').map(&:to_i)
            difference = dest_start_range - src_start_range
            current_map[:correspondences].push({
                range: src_start_range..(src_start_range + range_length - 1),
                difference: difference
            })
        end
    end
    maps << current_map if current_map.any?
    maps
end

def apply_map(seeds, map)
    seeds.map do |seed|
        map[:correspondences].each do |correspondence|
            if correspondence[:range].include?(seed)
                print "Applying range: #{correspondence[:range]} to seed #{seed} (#{correspondence[:difference]})\n"
                seed += correspondence[:difference]
                print "New value is #{seed}\n"
                break
            end
        end
        seed
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

# Parse input file
lines = file_content.split("\n")
seeds = parse_seeds(lines.shift)
print "The seeds are: #{seeds}\n\n"

maps = parse_mapping_maps(lines)

maps.each do |map|
    print "Applying map #{map[:name]} is:\n"
    print "Correspondences #{map[:correspondences]} is:\n"
    seeds = apply_map(seeds, map)
    print "Result is #{seeds}\n\n"
end

print "Lowest number is: #{seeds.sort.first}\n\n"
