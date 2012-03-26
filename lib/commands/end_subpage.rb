class DramaticPause
  def self.parse?(line, room = nil, enterpreter = nil)
    if line[0..2] == "---"
      new
    else
      false
    end
  end

  def code
    "$this->receiver->end_subpage();"
  end

end
