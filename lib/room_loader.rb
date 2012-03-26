require 'room'

class RoomLoader
  def initialize(folder)
    @folder = folder
  end

  def get(room_number)
    abort "Tried loading room #{room_number} that does not exist" unless room_exists?(room_number)
    @@last_loaded_room_number = room_number
    room = IO.read(path_to(room_number)).map { |line| line.gsub(/\s*$/, "") }.extend(Room)
    room.number = room_number
    room
  end

  def room_exists?(room_number)
    File.exists? path_to(room_number)
  end

  def all_room_numbers
    Dir["#{@folder}/**/A*.adv"].map { |filename| filename.scan(/A(\d+)\.adv$/) }.flatten.map { |s| s.to_i }
  end

  def self.last_loaded_room_number
    @@last_loaded_room_number ||= "none"
  end

  private

  def path_to(room_number)
    "#{@folder}/#{subfolder(room_number)}/#{roomfile(room_number)}"
  end

  def subfolder(room_number)
    hundreds = room_number.to_i / 100
    hundreds < 10 ? "A0#{hundreds}" : "A#{hundreds}"
  end

  def roomfile(room_number)
    "A#{room_number}.adv"
  end

end
