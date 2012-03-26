# -*- coding: utf-8 -*-
class CountVisits

  def self.parse?(line, room, enterpreter = nil)
    if line =~ /^:besøk \+\+ \(max (\d+)\)$/
      new room.number, $1
    else
      false
    end
  end

  def initialize(room_number, limit)
    @room_number, @limit = room_number, limit
  end

  def code
    wrap_in_if("$this->receiver->add_to_detail(\"\\$_VISITS_TO_#{@room_number}\", 1);")
  end

  private

  def wrap_in_if(statement)
    "if ($this->con($this->receiver->get_detail(\"\\$_VISITS_TO_#{@room_number}\") < #{@limit})) { #{statement} }"
  end

end
