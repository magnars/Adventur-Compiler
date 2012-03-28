require 'commands/if_statement'
require 'commands/conditional_command'
require 'conditional'
require 'room'

class RunSavedCommand
  def self.parse?(line, room, enterpreter)
    if line[0..2] === "<= "
      name = line[3..-1]
      commands = enterpreter.hashcode_keeper.contentlist_for(name).map do |content|
        conditional = OrConditional.new
        content.codes.each { |code| conditional << ValueConditional.new("]C[#{name}", "==", code) }
        command = enterpreter.current_command([content.text.clone].extend(Room))
        ConditionalCommand.new(conditional, command)
      end
      new commands
    else
      false
    end
  end

  def initialize(commands)
    @commands = commands
  end

  def code
    @commands.map { |c| c.code }.flatten
  end

end
