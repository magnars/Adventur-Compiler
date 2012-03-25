class SaveCommand
  def initialize(name, contents, hashcode_keeper)
    @name, @contents, @contents_hash = name, contents, hashcode_keeper.code_for(name, contents)
  end
  
  def self.parse?(line, room, enterpreter = nil)
    if line[0..2] === "]C["
      new line[3..-1], room.next, enterpreter.hashcode_keeper
    else
      false
    end
  end
  
  def code
    "$this->receiver->set_detail(\"]C[#{@name}\", \"#{@contents_hash}\");"
  end
  
end