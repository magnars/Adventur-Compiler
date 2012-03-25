class CountVisits
  
  def self.parse?(line, room, enterpreter = nil)
    if line === "[Y]"
      new room.number
    elsif line =~ /^\[Y\](\d+)$/
      new room.number, $1
    else
      false
    end
  end
  
  def initialize(room_number, limit = nil)
    @room_number, @limit = room_number, limit
  end
  
  def code
    wrap_in_if("$this->receiver->add_to_detail(\"\\$_VISITS_TO_#{@room_number}\", 1);")
  end
  
  private
  
  def wrap_in_if(statement)
    if @limit
      "if ($this->con($this->receiver->get_detail(\"\\$_VISITS_TO_#{@room_number}\") < #{@limit})) { #{statement} }"
    else
      statement
    end
  end
  
  
end