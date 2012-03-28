require 'test/unit'
require 'rubygems'
require 'mocha'
require 'commands/if_statement'
require 'commands/plain_text'
require 'room'

class CommandsIfStatementTestCase < Test::Unit::TestCase

  def setup
    room = ["? FLAG {", "content", "content", "}", "outside"].extend(Room)
    (@enterpreter = mock('enterpreter')).stubs(:current_command).returns(PlainText.new("content"))
    @bundle = IfStatement.parse?(room.current, room, @enterpreter)
  end

  def test_should_complain_about_missing_closing_brackets
    room = ["? FLAG {", "content"].extend(Room)
    assert_raise(RuntimeError) { IfStatement.parse?(room.current, room, @enterpreter) }
  end

  def test_should_build_code
    assert_equal(['if ($this->con($this->receiver->has_flag("FLAG"))) {',
                  '  $this->receiver->write("content");',
                  '  $this->receiver->write("content");',
                  '}'
                 ], @bundle.code)
  end

end
