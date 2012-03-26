class PlainText
  def initialize(text)
    @text = text
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
