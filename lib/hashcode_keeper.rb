
class HashcodeKeeper
  def initialize(hashcodefile = false)
    @variables = []
    parse hashcodefile if hashcodefile
  end
  
  def add(variable_name, content)
    find_or_create_variable(variable_name).add_content(content)
  end
  
  def contentlist_for(variable_name)
    variable(variable_name).contentlist
  end
  
  def code_for(variable_name, content)
    variable(variable_name).contentlist.find { |c| c.text == content }.codes.first
  end
  
  def variable(name)
    @variables.find { |var| var.name == name } or throw "Ukjent variabel #{name}"
  end

  def parse(hashcodefile)
    hashcodefile.to_s.split("\n\n").each { |variable| parse_variable variable.to_a.map { |string| string.chomp } }
  end
  
  def parse_variable(definition)
    name = definition.shift[3..-1]
    contentlist = []
    definition.each_slice(2) { |text, codes| contentlist << Content.new(text, codes.split(',').map { |code| code.to_i }) }
    @variables << Variable.new(name, contentlist)
  end
  
  def save(filename)
    File.open(filename, "w") do |file|
      @variables.each { |var| var.save(file); file.puts "" }
    end
  end
  
  private
  
  def find_or_create_variable(name)
    @variables << Variable.new(name) if not @variables.find { |var| var.name == name }
    @variables.find { |var| var.name == name }
  end
  
end

class Variable
  attr_reader :name, :contentlist
  
  def initialize(name, contentlist = [])
    @name, @contentlist = name, contentlist
  end
  
  def add_content(content)
    @contentlist << Content.new(content) unless @contentlist.any? { |c| c.text == content }
  end

  def save(file)
    file.puts "]C[#{@name}"
    @contentlist.each { |content| content.save(file) }
  end
  
end

class Content
  attr_reader :text

  def initialize(text, codes = [])
    @text, @codes = text, codes
  end

  def codes
    @codes << @text.hash if @codes.empty?
    @codes
  end
  
  def save(file)
    file.puts @text
    file.puts codes.join(",")
  end
  
end