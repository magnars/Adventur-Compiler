class RemoveAlternatives
  def self.parse?(line, room = nil, enterpreter = nil)
    if line =~ /^#(\d+)$/
      RemoveAlternatives.new $1
    else
      false
    end
  end
  
  def initialize(room_number)
    @room_number = room_number
  end
  
  def code
    "if ($this->con(!$this->receiver->has_flag(\"nr#{@room_number}\"))) { $this->receiver->add_flag(\"nr#{@room_number}\"); }"
  end
  
end