require 'test/unit'
require 'commands/unreachable'

class CommandsUnreachableTestCase < Test::Unit::TestCase

  def setup
    @story = Unreachable.parse?('$%&')
  end

  def test_should_build_no_code
    assert_equal([], @story.code)
  end

end
