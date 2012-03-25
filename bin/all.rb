require 'room_loader'
require 'page'
require 'change_tracker'

abort "Usage: all.rb [rooms folder]" unless ARGV.size == 1

def linked_room_numbers
  puts "finding all linked room numbers... "
  start = Time.now
  @links = [0]
  @visited = []
  @unvisited = [0]
  while not @unvisited.empty? do
    visit(@unvisited.first)
  end
  puts "done after #{Time.now - start} seconds."
  @links.uniq
end

def visit(number)
  @visited << number
  @unvisited.delete number
  links = find_links_in_room(number)
  @links += links
  links.each do |link|
    link = link.to_i
    if not @visited.include? link and File.exist? room_file(link)
      @unvisited << link
    end
  end
end

def find_links_in_room(number)
  lines = load_room(number)
  links = []
  previous = ""
  lines.each do |line|
    line = line.strip
    links += find_links(line, previous)
    previous = line
  end
  links.uniq
end

def find_links(line, previous)
  number = /^\d+$/
  if 
    line =~ LinkingCommands.jump_to or
    line =~ LinkingCommands.alternatives_from or
    line =~ LinkingCommands.procedure_call or
    line =~ LinkingCommands.conditional_jump
  then 
    [$1]
  elsif previous =~ LinkingCommands.change_room or
        previous =~ LinkingCommands.delayed_jump
    [line]
  elsif line =~ number and
        not previous =~ LinkingCommands.bodycount and
        not previous =~ LinkingCommands.alternative_separator
    [line]
  else 
    []
  end
end

def load_room(number)
  File.open(room_file(number)).readlines
end

def room_file(number)
  "#{ARGV[0]}/#{room_folder(number)}/A#{number}.txt"
end

def room_folder(number)
  prefix = number < 1000 ? "A0" : "A"
  folder = prefix + (number / 100).to_s
end

class LinkingCommands

  def self.jump_to
    /^@(\d+)$/
  end

  def self.alternatives_from
    /^\{@\}(\d+)$/
  end

  def self.procedure_call
    /^\(@\)(\d+)$/
  end

  def self.conditional_jump
    /^\[@\](\d+)$/
  end

  def self.change_room
    /^\[\](\d+)$/
  end

  def self.delayed_jump
    /^\{\}(\d+)$/
  end

  def self.bodycount
    /^\$\$\$$/
  end

  def self.alternative_separator
    /^(\-|\+)$/
  end

end

if $0 == __FILE__
  source_folder = ARGV[0]
  loader = RoomLoader.new source_folder
  coordinator = TimedJumpCoordinator.new loader
  destination = "../compiled_pages/#{File.basename(ARGV[0]).downcase}"
  linked_room_numbers.each do |number| 
    if File.exists?(room_file(number.to_i)) then
      puts "Compiling #{number}"
      page = Page.new(number, loader, coordinator)
      dir = number.to_i % 100
      Dir.mkdir("#{destination}/#{dir}") unless File.exists?("#{destination}/#{dir}")
      File.open("#{destination}/#{dir}/#{number}.php", "w") { |file| file.puts(page.code) }
      Dir.mkdir("#{destination}/versions/#{dir}") unless File.exists?("#{destination}/versions/#{dir}")
      File.open("#{destination}/versions/#{dir}/#{page.identifier}.php", "w") { |file| file.puts(page.code) }
    end
  end
  ChangeTracker.new(source_folder, destination).save_current_state!
end

