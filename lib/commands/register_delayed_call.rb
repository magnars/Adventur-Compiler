class RegisterDelayedCall

  def self.parse?(line, room, enterpreter = nil)
    if line =~ /^\(@\)(\d+) om (\d+) ...$/
      new $1, $2
    else
      false
    end
  end

  def initialize(destination, delay)
    @destination, @delay = destination, delay
  end

  def code
    [
      "$this->receiver->set_detail('$_CALL_DELAY', #{@delay});",
      "$this->receiver->set_detail('$_DELAYED_CALL', #{@destination});"
    ]
  end

end
