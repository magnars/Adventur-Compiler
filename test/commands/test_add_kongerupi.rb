require 'test/unit'
require 'commands/add_kongerupi'

class CommandsAddKongerupiTestCase < Test::Unit::TestCase

  def setup
    @add = AddKongerupi.parse?(":rupi +2")
    @sub = AddKongerupi.parse?(":rupi -23")
  end

  def test_should_build_code
    assert_equal('$this->receiver->add_to_detail("\$_KONGERUPI", 2);', @add.code)
    assert_equal('$this->receiver->add_to_detail("\$_KONGERUPI", -23);', @sub.code)
  end

end
