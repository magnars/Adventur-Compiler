class GotoRoom
  def initialize(room_number)
    @room_number = room_number
  end
  
  def self.parse?(line, room, enterpreter)
    if line[0..0] == "@"
      room_number = line[1..-1].to_i
      unless enterpreter.has_function("execute_room_#{room_number}")
        enterpreter.register_function("execute_room_#{room_number}")
        commands = enterpreter.parse(room_number)
        enterpreter.define_function("execute_room_#{room_number}", commands)
      end
      new room_number
    else
      false
    end
  end
  
  def code
    ["$this->receiver->room_number_changed(#{@room_number});",
     "$this->execute_room_#{@room_number}();",
     'return;'].flatten
  end
  
end