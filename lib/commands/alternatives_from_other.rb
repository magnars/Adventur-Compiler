class AlternativesFromOther
  def initialize(room_number, alternatives)
    @room_number, @alternatives = room_number, alternatives
  end

  def self.parse?(line, room, enterpreter)
    if line[0..2] == "{@}"
      room_number = line[3..-1].to_i
      other = enterpreter.room_loader.get(room_number)
      other.next until other.current == "=" or other.current == nil
      raise "Other room has no alternatives" if other.current == nil
      new room_number, enterpreter.current_command(other)
    else
      false
    end
  end

  def code
    ["$this->receiver->room_number_changed(#{@room_number});", @alternatives.code].flatten
  end

end
