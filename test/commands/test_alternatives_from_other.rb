require 'test/unit'
require 'rubygems'
require 'mocha'
require 'commands/alternatives_from_other'
require 'commands/plain_text'
require 'room'

class CommandsAlternativesFromOtherTestCase < Test::Unit::TestCase

  def setup
    @room = ['{@}17', 'should not show'].extend(Room)
    @room17 = ['should not show either', '=', 'alternative', '123'].extend(Room)
    room_loader = mock('room_loader')
    room_loader.expects(:get).with(17).returns(@room17)
    enterpreter = mock('enterpreter')
    enterpreter.stubs(:room_loader).returns(room_loader)
    enterpreter.expects(:current_command).with(@room17).returns(@alternatives = mock('alternatives'))
    @command = AlternativesFromOther.parse?(@room.current, @room, enterpreter)
  end

  def test_should_add_note_about_room_change
    @alternatives.expects(:code).returns("$this->code();")
    assert_equal(['$this->receiver->room_number_changed(17);', '$this->code();'], @command.code)
  end

  def test_should_complain_if_other_room_has_no_alternatives
    @room = ['{@}17'].extend(Room)
    @room17 = ['line 1', 'line 2'].extend(Room)
    room_loader = mock('room_loader')
    room_loader.expects(:get).with(17).returns(@room17)
    enterpreter = mock('enterpreter')
    enterpreter.stubs(:room_loader).returns(room_loader)
    assert_raise(RuntimeError) { AlternativesFromOther.parse?(@room.current, @room, enterpreter) }
  end

end
