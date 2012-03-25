require 'test/unit'
require 'commands/activate_saving'

class CommandsActivateSavingTestCase < Test::Unit::TestCase

  def setup
    @save = ActivateSaving.parse?("#SAVE# På torget")
  end

  def test_should_build_code
    assert_equal(['$this->receiver->set_detail("\$_LAGRINGSPLASS", "På torget");', '$this->receiver->saveable();'], @save.code)
  end

end