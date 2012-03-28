require 'test/unit'
require 'commands/end_subpage'

class CommandsDramaticPauseTestCase < Test::Unit::TestCase

  def setup
    @command1 = DramaticPause.parse?("--")
    @command2 = DramaticPause.parse?("---")
    @command3 = DramaticPause.parse?("-------")
  end

  def test_should_not_end_subpage_with_few
    assert(!@command1)
  end

  def test_should_end_the_subpage
    assert_equal('$this->receiver->end_subpage();', @command2.code)
    assert_equal('$this->receiver->end_subpage();', @command3.code)
  end

end
