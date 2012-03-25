require 'test/unit'
require 'commands/change_location'

class CommandsChangeLocationTestCase < Test::Unit::TestCase

  def setup
    @loc = ChangeLocation.parse?("=> Veslegrend")
  end

  def test_should_build_code
    assert_equal('// $this->receiver->set_detail("\$_STED", "Veslegrend");', @loc.code)
  end

end