class DramaticPause
  def self.parse?(line, room = nil, enterpreter = nil)
    if line === "!!!"
      new
    else
      false
    end
  end
  
  def code
    "$this->receiver->end_subpage();"
  end
  
end