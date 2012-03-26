class SummarizeDeeds
  def self.parse?(line, room, enterpreter)
    if line === ":gud-og-satan-krangler"
      new enterpreter.hashcode_keeper.contentlist_for("_EVIL_DEED"), enterpreter.hashcode_keeper.contentlist_for("_GOOD_DEED")
    else
      false
    end
  end

  def initialize(evil_deeds, good_deeds)
    @evil_deeds, @good_deeds = evil_deeds, good_deeds
  end

  def code
    code = [
      '$evil = array();',
      '$good = array();',
      '$seed = 0;'
    ]
    @evil_deeds.each do |deed|
      codeif = deed.codes.map { |c| "$this->receiver->has_flag(\"_EVIL_DEED_#{c}\")" }.join(" || ")
      code << "if ($this->con(#{codeif})) { $evil[] = \"#{escape(deed.text)} \"; $seed += #{deed.codes.first.to_s[0..2]}; }"
    end
    @good_deeds.each do |deed|
      codeif = deed.codes.map { |c| "$this->receiver->has_flag(\"_GOOD_DEED_#{c}\")" }.join(" || ")
      code << "if ($this->con(#{codeif})) { $good[] = \"#{escape(deed.text)} \"; $seed += #{deed.codes.first.to_s[0..2]}; }"
    end
    code << [
      'srand($seed);',
      'while (sizeof($good) > 0) {',
      '  $r = array_rand($good);',
      '  $this->receiver->write($good[$r]);',
      '  unset($good[$r]);',
      '  if (sizeof($evil) > 0) {',
      '    $r = array_rand($evil);',
      '    $this->receiver->write($evil[$r]);',
      '    unset($evil[$r]);',
      '  } else {',
      '    break;',
      '  }',
      '}'
    ]
    code.flatten
  end

  def escape(text)
    text.gsub('\\', ':BS::BS::BS::BS::BS:').gsub(':BS:', '\\').gsub('"', '\"').gsub("<navn>", '".$this->receiver->get_nickname()."')
  end

end
