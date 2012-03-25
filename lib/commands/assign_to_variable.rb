class AssignToVariable
  def self.parse?(line, room = nil, enterpreter = nil)
    case
    when line =~ /^(\$[^ ]+) ?= ?(.*)/ then new $1, $2
    when line =~ /^(\$[^ ]+)\+\+/ then new $1, "#{$1} + 1"
    when line =~ /^(\$[^ ]+)\-\-/ then new $1, "#{$1} - 1"
    when true then false
    end
  end
  
  def initialize(variable, expression)
    @variable, @expression = variable, expression
  end
  
  def code
    variable = escape(@variable)
    case
    when @expression =~ /^Tilfeldig: ([^ ]+) til ([^ ]+)$/ then "$this->receiver->set_to_random(\"#{variable}\", #{get_details($1)}, #{get_details($2)});"
    when @expression =~ /^#{variable} \+ (\d+)$/ then "$this->receiver->add_to_detail(\"#{variable}\", #{$1});"
    when @expression =~ /^#{variable} \- (\d+)$/ then "$this->receiver->add_to_detail(\"#{variable}\", -#{$1});"
    when true then "$this->receiver->set_detail(\"#{variable}\", #{get_details(@expression)});"
    end
  end
  
  private
  
  def escape(var)
    var.gsub('$', '\$')
  end

  def get_details(expression)
    expression.split(/(\$[^ ]+)/).map do |part|
      if part =~ /^\$([^ ]+)$/
        "$this->receiver->get_detail(\"\\$#{$1}\")"
      else
        part
      end
    end.join
  end
  
  
end