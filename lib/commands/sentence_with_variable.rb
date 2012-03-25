class SentenceWithVariable
  
  def self.parse?(line, room, enterpreter = nil)
    if line[0..2] === "[$]"
      new line[3..-1], room.next, room.next
    else
      false
    end
  end
  
  def initialize(value, multiple_text, single_text)
    @value, @multiple_text, @single_text = value, multiple_text, single_text
  end
  
  def code
    [
      "$value = $this->receiver->get_detail_to_display('#{@value}');",
      "if ($value == 1) {",
      "  $this->receiver->write(\"#{escape(@single_text)}\");",
      "} else if ($value) {",
      "  if (is_numeric($value)) { $value = TextFormatter::number($value); }",
      "  $lvalue = TextFormatter::lowercase($value);",
      "  $this->receiver->write(\"#{escape(@multiple_text)}\");",
      "}"
    ]
  end
  
  private
  
  def escape(text)
    text.sub(/^\$\$/, "$value").gsub("$$", "$lvalue").gsub('\\', ':BS::BS::BS::BS::BS:').gsub(':BS:', '\\').gsub('"', '\"')
  end
  
end