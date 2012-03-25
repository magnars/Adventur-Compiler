require 'test/unit'
require 'commands/remove_flag'

class CommandsRemoveFlagTestCase < Test::Unit::TestCase

  def test_should_remove_normal_flags
    command = RemoveFlag.parse?(")(FLAG")
    assert_equal('if ($this->con($this->receiver->has_flag("FLAG"))) { $this->receiver->remove_flag("FLAG"); }', command.code)
  end

  def test_should_remove_value_flags
    command = RemoveFlag.parse?(")($VAL")
    assert_equal('if ($this->con($this->receiver->has_flag("\$VAL"))) { $this->receiver->remove_flag("\$VAL"); }', command.code)
  end

end