class PlainText
  def initialize(text)
    @text = add_spaces_every_eighty(text)
  end
  
  def add_spaces_every_eighty(text)
    chars = text.split(//u)
    if chars.length > 80 then
      [chars[0..79], " ", add_spaces_every_eighty(chars[80..-1].join)].join
    else
      text
    end
  end
  
  def self.parse?(line, room = nil, enterpreter = nil)
    new(line)
  end
  
  def code
    "$this->receiver->write(\"#{escape(@text)}\");"
  end
  
  def escape(text)
    text.gsub('\\', ':BS::BS::BS::BS::BS:').gsub(':BS:', '\\').gsub('"', '\"').gsub("<navn>", '".$this->receiver->get_nickname()."')
  end
  
end