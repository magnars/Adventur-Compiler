# -*- coding: utf-8 -*-
require 'test/unit'
require 'commands/increase_bodycount'
require 'room'

class CommandsIncreaseBodycountTestCase < Test::Unit::TestCase

  def setup
    room = [':drap +3'].extend(Room)
    @command = IncreaseBodycount.parse?(room.current, room)
  end

  def test_should_generate_code
    assert_equal('$this->receiver->add_to_detail("\$_BODYCOUNT", 3);', @command.code)
  end

  def test_should_complain_about_illegal_values
    room = [':drap Du får en bodycount men det bør helst være et tall her også.'].extend(Room)
    assert_raise(RuntimeError) { IncreaseBodycount.parse?(room.current, room) }
  end

end
