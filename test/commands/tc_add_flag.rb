require 'test/unit'
require 'commands/add_flag'

class CommandsAddFlagTestCase < Test::Unit::TestCase

  def setup
    @command = AddFlag.parse?("()FLAG")
  end

  def test_should_only_parse_adding_of_flags
    assert(!AddFlag.parse?("some text"), "AddFlag should not parse plain text.")
    assert(!AddFlag.parse?(")(FLAG"), "AddFlag not parse )(FLAG).")
  end

  def test_should_build_code
    assert_equal('if ($this->con(!$this->receiver->has_flag("FLAG"))) { $this->receiver->add_flag("FLAG"); }', @command.code)
  end

end