require 'commands/conditional_command'
require 'commands/goto_room'
require 'conditional'
require 'cond_tree'

class ConditionalGoto
  def self.parse?(line, room, enterpreter)
    if line =~ /^@(\d+) \?\?$/
      conditional = Conditional.build([:not, "nr#{$1}"], room.number)
      command = GotoRoom.parse?("@#{$1}", room, enterpreter)
      ConditionalCommand.new conditional, command
    elsif line =~ /^@(\d+) \?\? (.+)$/
      implicit_condition = [:not, "nr#{$1}"]
      explicit_condition = CondTree.parse($2)
      if explicit_condition === "-"
        conditional = Conditional.build(implicit_condition, room.number)
      else
        both = [:and, implicit_condition, explicit_condition]
        conditional = Conditional.build(both, room.number)
      end
      command = GotoRoom.parse?("@#{$1}", room, enterpreter)
      ConditionalCommand.new conditional, command
    else
      false
    end
  end

end
