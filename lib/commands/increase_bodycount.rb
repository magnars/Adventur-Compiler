class IncreaseBodycount

  def self.parse?(line, room, enterpreter = nil)
    if line.sub!(/^:drap /, "")
      new(line.to_i)
    else
      false
    end
  end

  def initialize(count)
    raise "Bodycount was increased by '#{count}', which is not a valid bodycount increase." if count.to_i == 0
    @count = count
  end

  def code
    "$this->receiver->add_to_detail(\"\\$_BODYCOUNT\", #{@count});"
  end

end
