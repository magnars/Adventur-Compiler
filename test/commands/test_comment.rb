require 'test/unit'
require 'commands/comment'

class CommandsCommentTestCase < Test::Unit::TestCase

  def setup
    @story = Comment.parse?(';; min kommentar her')
  end

  def test_should_build_no_code
    assert_equal([], @story.code)
  end

end
