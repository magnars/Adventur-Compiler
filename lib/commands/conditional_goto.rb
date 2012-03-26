require 'commands/conditional_command'
require 'commands/goto_room'
require 'conditional'

class ConditionalGoto
  def self.parse?(line, room, enterpreter)
    if line =~ /^@(\d+) \?\?$/
      conditional = Conditional.parse(")(nr#{$1}")
      command = GotoRoom.parse?("@#{$1}", room, enterpreter)
      ConditionalCommand.new conditional, command
    elsif line =~ /^@(\d+) \?\? (.+)$/
      implicit_condition = ")(nr#{$1}"
      explicit_condition = $2
      if explicit_condition === "-"
        conditional = Conditional.parse(implicit_condition)
      else
        conditional = Conditional.parse(both_conditions(implicit_condition, explicit_condition))
      end
      command = GotoRoom.parse?("@#{$1}", room, enterpreter)
      ConditionalCommand.new conditional, command
    else
      false
    end
  end

  private

  def self.both_conditions(one, other)
    length = one.length < 10 ? "0#{one.length}" : one.length
    "+#{length}#{one}#{other}"
  end

end
