require 'test/unit'
require 'commands/add_deed'
require 'room'

class CommandsAddDeedTestCase < Test::Unit::TestCase

  def setup
    room = ['---', 'An evil deed'].extend(Room)
    @evil_deed = AddDeed.parse?(room.current, room)
    room = ['+++', 'A good deed'].extend(Room)
    @good_deed = AddDeed.parse?(room.current, room)
  end

  def test_should_generate_code
    assert_equal(expected_code_for_evil_deed, @evil_deed.code)
    assert_equal(expected_code_for_good_deed, @good_deed.code)
  end
  
  def expected_code_for_evil_deed
    [
      'if ($this->con(!$this->receiver->has_flag("_EVIL_DEED_389028181"))) {',
      '  $this->receiver->add_deed("EVIL");',
      '  $this->receiver->add_flag("_EVIL_DEED_389028181");',
      '}'
    ]
  end

  def expected_code_for_good_deed
    [
      'if ($this->con(!$this->receiver->has_flag("_GOOD_DEED_1072018006"))) {',
      '  $this->receiver->add_deed("GOOD");',
      '  $this->receiver->add_flag("_GOOD_DEED_1072018006");',
      '}'
    ]
  end
  

end