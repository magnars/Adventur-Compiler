require 'test/unit'
require 'room'
require 'commands/remove_alternatives'

class CommandsRemoveAlternativesTestCase < Test::Unit::TestCase

  def test_should_remove_alternatives
    command = RemoveAlternatives.parse?("#23")
    assert_equal('if ($this->con(!$this->receiver->has_flag("nr23"))) { $this->receiver->add_flag("nr23"); }', command.code)
  end

  def test_should_remove_alternatives_to_current_room
    room = ["#!"].extend(Room)
    room.number = 17
    command = RemoveAlternatives.parse?("#!", room)
    assert_equal('if ($this->con(!$this->receiver->has_flag("nr17"))) { $this->receiver->add_flag("nr17"); }', command.code)
  end

end
