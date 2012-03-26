class RemoveFlag
  def initialize(flag)
    @flag = flag
  end

  def self.parse?(line, room = nil, enterpreter = nil)
    if line[0..2] == "-- "
      new line[3..-1]
    else
      false
    end
  end

  def code
    "if ($this->con($this->receiver->has_flag(\"#{escape(@flag)}\"))) { $this->receiver->remove_flag(\"#{escape(@flag)}\"); }"
  end

  private

  def escape(var)
    var.gsub('$', '\$')
  end


end
