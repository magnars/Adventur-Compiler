require 'test/unit'
require 'commands/end_paragraph'

class CommandsEndParagraphTestCase < Test::Unit::TestCase

  def setup
    @p = EndParagraph.parse?("")
  end

  def test_should_build_code
    assert_equal("$this->receiver->end_paragraph();", @p.code)
  end

end