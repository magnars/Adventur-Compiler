require 'commands/command_bundle'
require 'commands/conditional_command'
require 'conditional'
require 'room'

class RunSavedCommand
  def self.parse?(line, room, enterpreter)
    if line[0..2] === "[C]"
      name = line[3..-1]
      commands = enterpreter.hashcode_keeper.contentlist_for(name).map do |content|
        conditional = OrConditional.new
        content.codes.each { |code| conditional << ValueConditional.new("]C[#{name}", "==", code) }
        command = enterpreter.current_command([content.text.clone].extend(Room))
        ConditionalCommand.new(conditional, command)
      end
      new CommandBundle.new(commands)
    else
      false
    end
  end
  
  def initialize(command)
    @command = command
  end
  
  def code
    @command.code
  end
  
end
