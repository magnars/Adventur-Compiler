require 'test/unit'
require 'commands/unfinished_story'

class CommandsUnfinishedStoryTestCase < Test::Unit::TestCase

  def setup
    @story = UnfinishedStory.parse?(':uferdig => Jan "Rudolf" Hansen')
  end

  def test_should_build_code
    assert_equal('$this->receiver->unfinished_story("Jan \"Rudolf\" Hansen");', @story.code)
  end

end
