require 'conditional'

class ConditionalCommand
  attr_reader :command

  def initialize(conditional, command)
    @conditional, @command = conditional, command
  end

  def self.parse?(line, room, enterpreter)
    if line.sub!(/ \? (.+)/, "")
      conditional = Conditional.parse($1)
      room[room.index] = line # replace with non-conditional before enterpreting again
      new(conditional, enterpreter.current_command(room))
    else
      false
    end
  end

  # def self.parse?(line, room, enterpreter)
  #   if line.sub!(/^\[\!\]/, "")
  #     room.next
  #     new(Conditional.parse(line), enterpreter.current_command(room))
  #   elsif line =~ /^\[X!\](\d+)$/
  #     room.next
  #     new(Conditional.parse("$_VISITS_TO_#{room.number} == #{$1}"), enterpreter.current_command(room))
  #   else
  #     false
  #   end
  # end

  def code
    if @conditional.is_a? TrueConditional
      @command.code
    elsif @conditional.is_a? FalseConditional
      []
    else
      [ "if ($this->con(#{@conditional.code})) {",
        @command.code.map { |line| "  #{line}" },
        '}'].flatten
    end
  end

end
