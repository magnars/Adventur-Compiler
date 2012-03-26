class Comment

  def self.parse?(line, room = nil, enterpreter = nil)
    if line[0..1] === ";;"
      new
    else
      false
    end
  end

  def code
    []
  end

end
