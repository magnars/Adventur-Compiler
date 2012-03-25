module Room
  attr_accessor :number
  
  def current
    self[index]
  end
  
  def next
    @index = index + 1
    current
  end
  
  def peek
    self[index+1]
  end
  
  def index
    @index ||= 0
  end
end