require 'commands/conditional_command'

class Alternatives
  def initialize(alternatives)
    @alternatives = alternatives
  end
  
  def self.parse?(line, room, enterpreter)
    if line == "-" or line == "+"
      if room.peek == "}"
        return CancelProcedureCall.new
      end
      room_loader = enterpreter.room_loader
      num = room.next.to_i
      alternatives = []
      num.times do
        alternative = Alternative.new(room.next, room.next.lstrip)
        condition = line == "+" ? room.next : "-"
        next unless room_loader.room_exists? alternative.room_number
        alternatives << ConditionalCommand.new(Conditional.parse(condition), alternative)
      end
      raise "Alternatives must be last in block or room. Saw: ['#{room.peek}']" unless room.peek == nil or room.peek == "}"
      new alternatives
    else
      false
    end
  end
  
  def code
    ['$visible_alternatives = 0;', @alternatives.map { |a| a.code }, 'return;'].flatten
  end
  
end

class Alternative
  attr_reader :text, :room_number
  
  def initialize(text, room_number)
    @text, @room_number = text, room_number
  end
  
  def code
    "if ($this->con(!$this->receiver->has_flag(\"nr#{@room_number}\"))) { $this->receiver->add_alternative(\"#{escape(@text)}\", #{@room_number}); $visible_alternatives++; }"
  end
  
  def escape(text)
    text.gsub('\\', ':BS::BS::BS::BS::BS:').gsub(':BS:', '\\').gsub('"', '\"').gsub("<navn>", '".$this->receiver->get_nickname()."')
  end
  
end

class CancelProcedureCall
  def code
    "return true;"
  end
end