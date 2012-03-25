class AddDeed
  def self.parse?(line, room, enterpreter = nil)
    if line === "---" or line === "+++"
      AddDeed.new(line, room.next)
    else
      false
    end
  end
  
  def initialize(type, description)
    @type, @description = type, description
  end
  
  def code
    type = @type === "---" ? "EVIL" : "GOOD"
    flag = "_#{type}_DEED_#{@description.hash}"
    [
      "if ($this->con(!$this->receiver->has_flag(\"#{flag}\"))) {",
      "  $this->receiver->add_deed(\"#{type}\");",
      "  $this->receiver->add_flag(\"#{flag}\");",
      "}"
    ]    
  end

end