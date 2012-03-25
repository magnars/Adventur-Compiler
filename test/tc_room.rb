require 'test/unit'
require 'room'

class RoomTestCase < Test::Unit::TestCase

  def setup
    @room = ["line1", "line2", "line3"].extend(Room)
  end

  def test_should_show_current_line
    assert_equal("line1", @room.current)
  end
  
  def test_should_jump_to_next_line
    assert_equal("line2", @room.next)
    assert_equal("line2", @room.current)
  end

  def test_should_allow_peeking_at_next
    assert_equal("line2", @room.peek)
    assert_equal("line1", @room.current)
  end
  
  def test_should_hold_room_number
    @room.number = 23
    assert_equal(23, @room.number)
  end

end