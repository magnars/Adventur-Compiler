class UnfinishedStory
  
  def self.parse?(line, room = nil, enterpreter = nil)
    if line[0..8] === "#UFERDIG#"
      new line[9..-1].lstrip
    else
      false
    end
  end
  
  def initialize(description)
    @description = description
  end
  
  def code
    "$this->receiver->unfinished_story(\"#{escape(@description)}\");"
  end

  def escape(text)
    text.gsub('\\', ':BS::BS::BS::BS::BS:').gsub(':BS:', '\\').gsub('"', '\"').gsub("<navn>", '".$this->receiver->get_nickname()."')
  end
  
  
end