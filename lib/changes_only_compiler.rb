require 'room_loader'
require 'timed_jump_coordinator'
require 'page'
require 'change_tracker'

class ChangesOnlyCompiler
  attr_accessor :source_directory, :target_directory, :change_tracker, :room_loader
  
  def initialize(source_directory, always_compile = [])
    @source_directory = source_directory
    @target_directory = "../compiled_pages/#{File.basename(source_directory).downcase}"
    @room_loader = RoomLoader.new source_directory
    @coordinator = TimedJumpCoordinator.new @room_loader
    @change_tracker = ChangeTracker.new @source_directory, @target_directory
    @always_compile = always_compile
  end

  def compile!
    affected_rooms.each do |number|
      if @room_loader.room_exists?(number)
        puts "Compiling #{number}"
        page = Page.new(number, @room_loader, @coordinator)
        dir = number.to_i % 100
        Dir.mkdir("#{@target_directory}/#{dir}") unless File.exists?("#{@target_directory}/#{dir}")
        File.open("#{@target_directory}/#{dir}/#{number}.php", "w") { |file| file.puts(page.code) }
        Dir.mkdir("#{@target_directory}/versions/#{dir}") unless File.exists?("#{@target_directory}/versions/#{dir}")
        File.open("#{@target_directory}/versions/#{dir}/#{page.identifier}.php", "w") { |file| file.puts(page.code) }
      else
        puts "Warning - #{number} used to depend on a changed room, but no longer exists"
      end
    end
    @change_tracker.save_current_state!
  end
  
  def affected_rooms
    affected_rooms = @change_tracker.changed_rooms.map { |room| find_affected_rooms_for(room) }.flatten
    affected_rooms << @always_compile if affected_rooms.size > 0
    affected_rooms.flatten.sort.uniq.reverse
  end
  
  def find_affected_rooms_for(room)
    rooms_dependent_on[room] || [room]
  end
  
  def rooms_dependent_on
    @rooms_dependencies ||= find_room_dependencies
  end
  
  def find_room_dependencies
    puts "finding all room dependencies... "
    start = Time.now
    dependencies = {}
    lines = `cd #{@target_directory} && find 0*/*.php -print | xargs grep -H "room_number_changed"`.to_a +
            `cd #{@target_directory} && find 1*/*.php -print | xargs grep -H "room_number_changed"`.to_a +
            `cd #{@target_directory} && find 2*/*.php -print | xargs grep -H "room_number_changed"`.to_a +
            `cd #{@target_directory} && find 3*/*.php -print | xargs grep -H "room_number_changed"`.to_a +
            `cd #{@target_directory} && find 4*/*.php -print | xargs grep -H "room_number_changed"`.to_a +
            `cd #{@target_directory} && find 5*/*.php -print | xargs grep -H "room_number_changed"`.to_a +
            `cd #{@target_directory} && find 6*/*.php -print | xargs grep -H "room_number_changed"`.to_a +
            `cd #{@target_directory} && find 7*/*.php -print | xargs grep -H "room_number_changed"`.to_a +
            `cd #{@target_directory} && find 8*/*.php -print | xargs grep -H "room_number_changed"`.to_a +
            `cd #{@target_directory} && find 9*/*.php -print | xargs grep -H "room_number_changed"`.to_a
    lines.each do |line|
      (dependencies[$2.to_i] ||= []) << $1.to_i if line =~ /(\d+)\.php:\s+\$this->receiver->room_number_changed\((\d+)\);/
    end
    puts "done after #{Time.now - start} seconds."
    dependencies
  end
  
end