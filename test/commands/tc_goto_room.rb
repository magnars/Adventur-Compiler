require 'test/unit'
require 'rubygems'
require 'mocha'
require 'commands/goto_room'
require 'commands/plain_text'
require 'room'

class CommandsGotoRoomTestCase < Test::Unit::TestCase

  def setup
    @room = ['@6', 'should not show'].extend(Room)
    enterpreter = mock('enterpreter')
    enterpreter.expects(:parse).with(6).returns(commands = [PlainText.new("contents")])
    enterpreter.stubs(:has_function).returns(false)
    enterpreter.expects(:register_function).with("execute_room_6")
    enterpreter.expects(:define_function).with("execute_room_6", commands)
    @command = GotoRoom.parse?(@room.current, @room, enterpreter)
  end

  def test_should_build_code
    assert_equal(['$this->receiver->room_number_changed(6);', '$this->execute_room_6();', 'return;'], @command.code)
  end
  
end