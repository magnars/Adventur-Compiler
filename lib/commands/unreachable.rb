class Unreachable

  def self.parse?(line, room = nil, enterpreter = nil)
    if line === "$%&"
      new
    else
      false
    end
  end

  def code
    []
  end

end
