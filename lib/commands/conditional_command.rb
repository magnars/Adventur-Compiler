require 'conditional'

class ConditionalCommand
  attr_reader :command

  def initialize(conditional, command)
    @conditional, @command = conditional, command
  end

  def self.parse?(line, room, enterpreter)
    if line.sub!(/ \?\? (.+)/, "")
      conditional = Conditional.parse($1, room.number)
      room[room.index] = line # replace with non-conditional before enterpreting again
      new(conditional, enterpreter.current_command(room))
    else
      false
    end
  end

  def code
    if @conditional.is_a? TrueConditional
      @command.code
    else
      [ "if ($this->con(#{@conditional.code})) {",
        @command.code.map { |line| "  #{line}" },
        '}'].flatten
    end
  end

end
