class ActivateSaving
  
  def self.parse?(line, room = nil, enterpreter = nil)
    if line[0..5] === "#SAVE#"
      new line[6..-1].lstrip
    else
      false
    end
  end
  
  def initialize(location)
    @location = location
  end
  
  def code
    [
      '$this->receiver->set_detail("\$_LAGRINGSPLASS", "' + @location + '");',
      '$this->receiver->saveable();'
    ]
  end
  
end