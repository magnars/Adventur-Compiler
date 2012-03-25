class RegisterDelayedCall
  
  def self.parse?(line, room, enterpreter = nil)
    if line[0..1] === "{}"
      new line[2..-1], room.next
    else
      false
    end
  end
  
  def initialize(delay, destination)
    @delay, @destination = delay, destination
  end
  
  def code
    [
      "$this->receiver->set_detail('$_CALL_DELAY', #{@delay});",
      "$this->receiver->set_detail('$_DELAYED_CALL', #{@destination});"
    ]
  end
  
end