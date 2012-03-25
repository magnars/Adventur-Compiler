require 'test/unit'
require 'commands/unfinished_story'

class CommandsUnfinishedStoryTestCase < Test::Unit::TestCase

  def setup
    @story = UnfinishedStory.parse?('#UFERDIG# Historien om "Rudolf" er ikke ferdig skrevet.')
  end

  def test_should_build_code
    assert_equal('$this->receiver->unfinished_story("Historien om \"Rudolf\" er ikke ferdig skrevet.");', @story.code)
  end

end