require 'test/unit'
require 'commands/end_subpage'

class CommandsDramaticPauseTestCase < Test::Unit::TestCase

  def setup
    @command = DramaticPause.parse?("!!!")
  end

  def test_should_end_the_subpage
    assert_equal('$this->receiver->end_subpage();', @command.code)
  end

end
