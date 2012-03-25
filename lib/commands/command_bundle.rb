class CommandBundle
  def initialize(commands)
    @commands = commands
  end
  
  def self.parse?(line, room, enterpreter)
    if line == "{"
      commands = []
      until room.next == "}"
        raise "Missing closing bracket" if room.current == nil
        commands << enterpreter.current_command(room)
      end
      new(commands)
    else
      false
    end
  end
  
  def code
    @commands.map { |c| c.code }.flatten
  end
  
end