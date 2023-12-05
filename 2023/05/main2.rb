def parse_seeds(seeds_line)
    seeds = []
    _, seeds_data = seeds_line.split(':')
    seeds_data.split(' ').map(&:to_i).each_slice(2).each do |pairs|
        seeds.push((pairs.first..(pairs.first + pairs.last - 1)))
    end
    seeds
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
    output = []
    seeds.each do |seed|
        matched = false
        map[:correspondences].each do |correspondence|
            overlap_range = range_overlap(seed, correspondence[:range])
            unless overlap_range.nil?
                matched = true
                if overlap_range.first > seed.first
                    seeds.push(seed.first..(overlap_range.first - 1))
                end

                output.push((overlap_range.first + correspondence[:difference])..(overlap_range.last + correspondence[:difference]))

                if overlap_range.last < seed.last
                    seeds.push((overlap_range.last + 1)..seed.last)
                end
                break
            end
        end
        output.push(seed) unless matched
    end
    output
end

def range_overlap(range1, range2)
    start = [range1.first, range2.first].max
    ending = [range1.last, range2.last].min
    start <= ending ? (start..ending) : nil
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

print "Lowest number is: #{seeds.map(&:first).sort.first}\n\n"
