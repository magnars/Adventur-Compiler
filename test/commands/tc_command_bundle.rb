require 'test/unit'
require 'rubygems'
require 'mocha'
require 'commands/command_bundle'
require 'commands/plain_text'
require 'room'

class CommandsCommandBundleTestCase < Test::Unit::TestCase

  def setup
    room = ["{", "content", "content", "}", "outside"].extend(Room)
    (@enterpreter = mock('enterpreter')).stubs(:current_command).returns(PlainText.new("content"))
    @bundle = CommandBundle.parse?(room.current, room, @enterpreter)
  end

  def test_should_complain_about_missing_closing_brackets
    room = ["{", "content"].extend(Room)
    assert_raise(RuntimeError) { CommandBundle.parse?(room.current, room, @enterpreter) }
  end

  def test_should_build_code
    assert_equal(['$this->receiver->write("content");', '$this->receiver->write("content");'], @bundle.code)
  end

end