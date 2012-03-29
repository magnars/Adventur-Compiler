require 'test/unit'
require 'commands/reinstate_alternatives'

class CommandsReinstateAlternativesTestCase < Test::Unit::TestCase

  def test_should_expose_contents_and_build_code
    command = ReinstateAlternatives.parse?("*872")
    assert_equal('if ($this->con($this->receiver->has_flag("nr872"))) { $this->receiver->remove_flag("nr872"); }', command.code)
  end

  def test_should_let_non_numeric_be
    assert !ReinstateAlternatives.parse?("*wow*")
  end


end
