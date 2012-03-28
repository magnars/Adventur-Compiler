require "conditional"

class IfStatement
  def initialize(conditional, commands)
    @conditional, @commands = conditional, commands
  end

  def self.parse?(line, room, enterpreter)
    if line =~ /^\? (.+) \{$/
      cond = Conditional.parse($1, room.number)
      commands = []
      until room.next == "}"
        raise "Missing closing bracket" if room.current == nil
        commands << enterpreter.current_command(room)
      end
      new(cond, commands)
    else
      false
    end
  end

  def code
    codes = @commands.map { |c| c.code }.flatten
    [ "if ($this->con(#{@conditional.code})) {",
      codes.map { |line| "  #{line}" },
      '}'].flatten
  end

end
