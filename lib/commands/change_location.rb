class ChangeLocation
  
  def self.parse?(line, room = nil, enterpreter = nil)
    if line[0..1] === "=>"
      new line[2..-1].lstrip
    else
      false
    end
  end
  
  def initialize(location)
    @location = location
  end
  
  def code
    '// $this->receiver->set_detail("\$_STED", "' + @location + '");'
  end
  
end