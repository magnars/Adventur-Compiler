class AddFlag
  def initialize(flag)
    @flag = flag
  end
  
  def self.parse?(line, room = nil, enterpreter = nil)
    if line.sub!(/^\(\)/, "")
      new(line)
    else
      false
    end
  end
  
  def code
    "if ($this->con(!$this->receiver->has_flag(\"#{@flag}\"))) { $this->receiver->add_flag(\"#{@flag}\"); }"
  end
  
end