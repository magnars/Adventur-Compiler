require 'test/unit'
require 'commands/add_timejump'

class CommandsAddTimejumpTestCase < Test::Unit::TestCase

  def setup
    @command = AddTimejump.parse?("$$$")
  end

  def test_should_build_code
    assert_equal('$this->receiver->add_timejump();', @command.code)
  end

end