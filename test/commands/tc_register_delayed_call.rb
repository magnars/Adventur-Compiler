require 'test/unit'
require 'commands/register_delayed_call'
require 'room'

class CommandsRegisterDelayedCallTestCase < Test::Unit::TestCase

  def setup
    room = ['{}3', '177'].extend(Room)
    @command = RegisterDelayedCall.parse?(room.first, room)
  end

  def test_should_generate_code
    assert_equal(expected_code, @command.code)
  end

  def expected_code
    [
      "$this->receiver->set_detail('$_CALL_DELAY', 3);",
      "$this->receiver->set_detail('$_DELAYED_CALL', 177);"
    ]
  end

end