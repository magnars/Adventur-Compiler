class AddDeed
  def self.parse?(line, room, enterpreter = nil)
    if line.start_with?(":slem => ")
      AddDeed.new("EVIL", line[9..-1])
    elsif line.start_with?(":snill => ")
      AddDeed.new("GOOD", line[10..-1])
    else
      false
    end
  end

  def initialize(type, description)
    @type, @description = type, description
  end

  def code
    flag = "_#{@type}_DEED_#{@description.hash}"
    [
      "if ($this->con(!$this->receiver->has_flag(\"#{flag}\"))) {",
      "  $this->receiver->add_deed(\"#{@type}\");",
      "  $this->receiver->add_flag(\"#{flag}\");",
      "}"
    ]
  end

end
