require 'test/unit'
require 'commands/add_timejump'

class CommandsAddTimejumpTestCase < Test::Unit::TestCase

  def setup
    @command = AddTimejump.parse?(":tidshopp +3")
  end

  def test_should_build_code
    assert_equal('$this->receiver->add_timejumps(3);', @command.code)
  end

end
