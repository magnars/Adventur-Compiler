# -*- coding: utf-8 -*-
require 'test/unit'
require 'commands/count_visits'
require 'room'

class CommandsCountVisitsTestCase < Test::Unit::TestCase

  def test_should_count_limited_visits
    room = [':besøk ++ (max 4)'].extend(Room)
    room.number = 7
    command = CountVisits.parse?(room.current, room)
    assert_equal('if ($this->con($this->receiver->get_detail("\$_VISITS_TO_7") < 4)) { $this->receiver->add_to_detail("\$_VISITS_TO_7", 1); }', command.code)
  end

end
