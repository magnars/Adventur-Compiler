class Conditional
  def self.conditionals
    [
     TrueConditional,
     NotConditional,
     AndConditional,
     AllConditional,
     OrConditional,
     SomeConditional,
     ThisButNotThatConditional,
     NotThisWithoutThatConditional,
     DateConditional,
     KongerupiConditional,
     ValueConditional,
     AlternativeNumberConditional,
     FlagConditional
    ]
  end

  def self.parse(node)
    conditionals.inject(false) do |conditional, kind|
      conditional = kind.parse?(node) and break conditional
    end
  end
end

class TrueConditional
  def self.parse?(node)
    if node === "-" then
      new
    else
      false
    end
  end

  def code
    return "true"
  end
end

class DateConditional
  def self.parse?(node)
    if node =~ /^DATO(\d\d\d\d)$/ then
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

class FlagConditional
  def self.parse?(node)
    new node
  end

  def initialize(flag)
    @flag = flag
  end

  def code
    "$this->receiver->has_flag(\"#{@flag}\")"
  end
end

class NotConditional
  def self.parse?(node)
    if node[0] == :not then
      NotConditional.new(Conditional.parse(node[1]))
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
  def self.parse?(node)
    if node[0] == :and then
      one = Conditional.parse(node[1])
      other = Conditional.parse(node[2])
      instance = new
      instance << one
      instance << other
      instance
    else
      false
    end
  end

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
    ops = @options.map { |o| o.code }.join(" && ")
    "(#{ops})"
  end
end

class AllConditional
  def self.parse?(node)
    if node[0] == :all then
      instance = AndConditional.new
      node[1..-1].each { |n| instance << Conditional.parse(n) }
      instance
    else
      false
    end
  end
end

class OrConditional
  def self.parse?(node)
    if node[0] == :or then
      one = Conditional.parse(node[1])
      other = Conditional.parse(node[2])
      instance = new
      instance << one
      instance << other
      instance
    else
      false
    end
  end

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
    "(#{ops})"
  end
end

class SomeConditional
  def self.parse?(node)
    if node[0] == :some then
      instance = OrConditional.new
      node[1..-1].each { |n| instance << Conditional.parse(n) }
      instance
    else
      false
    end
  end
end

class ThisButNotThatConditional
  def self.parse?(node)
    if node[0] == :this_but_not_that then
      this = Conditional.parse(node[1])
      that = Conditional.parse(node[2])
      new this, that
    else
      false
    end
  end

  def initialize(this, that)
    @this, @that = this, that
  end

  def code
    "(#{@this.code} && !#{@that.code})"
  end
end

class NotThisWithoutThatConditional
  def self.parse?(node)
    if node[0] == :not_this_without_that then
      this = Conditional.parse(node[1])
      that = Conditional.parse(node[2])
      new this, that
    else
      false
    end
  end

  def initialize(this, that)
    @this, @that = this, that
  end

  def code
    "(!#{@this.code} || #{@that.code})"
  end
end

class AlternativeNumberConditional
  def self.parse?(node)
    if node =~ /^\*(\d+)\*$/ then
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
  def self.parse?(node)
    if node =~ /^(.*) (<|<=|==|!=|>=|>) (.*)/ then
      new $1, $2, $3
    elsif node =~ /^(\$[\S]+|\-?\d+)$/ then
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
      if part == "$_MND" then
        'date("m")'
      elsif part == "$_DATO" then
        'date("H") > 4 && date("d")'
      elsif part =~ /^\$([^ ]+)$/ then
        "$this->receiver->get_detail(\"\\$#{$1}\")"
      elsif part =~ /^\]C\[([^ ]+)$/ then
        "$this->receiver->get_detail(\"]C[#{$1}\")"
      else
        part
      end
    end.join
  end

end

class KongerupiConditional
  def self.parse?(node)
    if node =~ /^kr\.(\d+)$/ then
      ValueConditional.new "$_KONGERUPI", ">=", $1
    else
      false
    end
  end
end
