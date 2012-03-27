require 'commands/conditional_command'

class Alternatives
  def initialize(alternatives)
    @alternatives = alternatives
  end

  def self.parse?(line, room, enterpreter)
    if line == "="
      return CancelProcedureCall.new if room.peek.nil?

      room_loader = enterpreter.room_loader
      alternatives = []

      while room.peek
        alternatives << parse_alternative(room)
      end

      alternatives = alternatives.select do |alt|
        room_loader.room_exists? alt.command.room_number
      end

      new alternatives
    else
      false
    end
  end

  def self.parse_alternative(room)
    text = room.next
    until room.peek =~ /^ *@/
      raise "Irregular alternatives at: #{room.current}" if room.peek.nil?
      text = "#{text} #{room.next}"
    end
    details = room.next
    if details =~ /^ *@(\d+)$/
      room_number = $1
      condition = "-"
    elsif details =~ /^ *@(\d+) \? (.+)$/
      room_number = $1
      condition = $2
    else
    end
    room.next if room.peek == "" # support blank line between alternatives
    alternative = Alternative.new(text, room_number)
    ConditionalCommand.new(Conditional.parse(condition), alternative)
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
