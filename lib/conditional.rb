class Conditional
  def self.parse(text)
    [TrueConditional, FalseConditional, NotConditional, AndConditional, DateConditional, KongerupiConditional, ValueConditional, AlternativeNumberConditional, FlagConditional].inject(false) do |conditional, kind|
      conditional = kind.parse?(text) and break conditional
    end
  end
end

class TrueConditional
  def self.parse?(text)
    if text === "-"
      new
    else
      false
    end
  end
  
  def code
    return "true"
  end
end

class FalseConditional
  def self.parse?(text)
    if text === ")(-"
      new
    else
      false
    end
  end
  
  def code
    return "false"
  end
end

class FlagConditional
  def self.parse?(text)
    new text
  end
  
  def initialize(flag)
    @flag = flag
  end
  
  def code
    "$this->receiver->has_flag(\"#{@flag}\")"
  end
end

class NotConditional
  def self.parse?(text)
    if text[0..1] === ")("
      NotConditional.new(Conditional.parse(text[2..-1]))
    else
      false
    end
  end
  
  def initialize(conditional)
    @conditional = conditional
  end
  
  def code
    "!(#{@conditional.code})"
  end
end

class AndConditional
  def self.parse?(text)
    if text =~ /^\+(\d\d)(.*)/
      length = $1.to_i
      one = Conditional.parse(cut_safely($2, 0, length - 1))
      other = Conditional.parse(cut_safely($2, length, -1))
      new one, other
    else
      false
    end
  end
  
  def initialize(one, other)
    @one, @other = one, other
  end
  
  def code
    "(#{@one.code} && #{@other.code})"
  end
  
  private
  
  def self.cut_safely(string, from, to)
    string.split(//u)[from..to].join
  end
  
end

class OrConditional
  def initialize
    @options = []
  end
  
  def add(conditional)
    @options << conditional
  end

  def <<(conditional)
    add(conditional)
  end
  
  def code
    ops = @options.map { |o| o.code }.join(" || ")
    "#{ops}"
  end  
end

class AlternativeNumberConditional
  def self.parse?(text)
    if text =~ /^\*(\d+)\*$/
      new $1
    else
      false
    end
  end

  def initialize(number)
    @number = number
  end
  
  def code
    "$visible_alternatives <= #{@number}"
  end  
end

class ValueConditional
  def self.parse?(text)
    if text =~ /^(.*) (<|<=|==|!=|>=|>) (.*)/
      new $1, $2, $3
    elsif text =~ /^(\$[\S]+|\-?\d+)$/
      new $1, '>', '0'
    else
      false
    end
  end
  
  def initialize(operand1, operator, operand2)
    @operand1, @operator, @operand2 = operand1.to_s, operator, operand2.to_s
  end
  
  def code
    [get_details(@operand1), @operator, get_details(@operand2)].join(" ")
  end
  
  private

  def get_details(expression)
    expression.split(/(\$[^ ]+)/).map do |part|
      if part == "$_MND"
        'date("m")'
      elsif part == "$_DATO"
        'date("H") > 4 && date("d")'
      elsif part =~ /^\$([^ ]+)$/
        "$this->receiver->get_detail(\"\\$#{$1}\")"
      elsif part =~ /^\]C\[([^ ]+)$/
        "$this->receiver->get_detail(\"]C[#{$1}\")"
      else
        part
      end
    end.join
  end
    
end

class KongerupiConditional
  def self.parse?(text)
    if text =~ /^kr\.(\d+)$/
      ValueConditional.new "$_KONGERUPI", ">=", $1
    else
      false
    end
  end
end

class DateConditional
  def self.parse?(text)
    if text =~ /^DATO(\d\d\d\d)$/
      new $1
    else
      false
    end
  end
  
  def initialize(date)
    @date = date
  end
  
  def code
    "date(\"H\") > 4 && date(\"dm\") == \"#{@date}\""
  end
  
end
