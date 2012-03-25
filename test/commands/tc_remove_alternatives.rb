require 'test/unit'
require 'commands/remove_alternatives'

class CommandsRemoveAlternativesTestCase < Test::Unit::TestCase

  def test_should_remove_alternatives
    command = RemoveAlternatives.parse?("#23")
    assert_equal('if ($this->con(!$this->receiver->has_flag("nr23"))) { $this->receiver->add_flag("nr23"); }', command.code)
  end

end