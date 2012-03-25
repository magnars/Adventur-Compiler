class AddTimejump
  
  def self.parse?(line, room = nil, enterpreter = nil)
    if line === "$$$"
      new
    else
      false
    end
  end
  
  def code
    '$this->receiver->add_timejump();'
  end
  
end