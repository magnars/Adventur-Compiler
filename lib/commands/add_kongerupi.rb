class AddKongerupi

  def self.parse?(line, room = nil, enterpreter = nil)
    if line[0..5] === ":rupi "
      AddKongerupi.new line[6..-1].to_i
    else
      false
    end
  end

  def initialize(amount)
    @amount = amount
  end

  def code
    "$this->receiver->add_to_detail(\"\\$_KONGERUPI\", #{@amount});"
  end

end
