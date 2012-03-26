class AddTimejump
  def initialize(num)
    @num = num
  end

  def self.parse?(line, room = nil, enterpreter = nil)
    if line.sub!(/^:tidshopp /, "")
      new(line.to_i)
    else
      false
    end
  end

  def code
    "$this->receiver->add_timejumps(#{@num});"
  end

end
