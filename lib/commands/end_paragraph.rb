class EndParagraph
  def self.parse?(line, room = nil, enterpreter = nil)
    if line === ""
      new
    else
      false
    end
  end
  
  def code
    "$this->receiver->end_paragraph();"
  end
end