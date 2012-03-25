require 'test/unit'
require 'rubygems'
require 'mocha'
require 'commands/alternatives'
require 'room'
require 'enterpreter'

class CommandsAlternativesTestCase < Test::Unit::TestCase

  def setup
    @room_loader = mock('room_loader')
    @room_loader.stubs(:room_exists?).returns(true)
    @enterpreter = mock('enterpreter')
    @enterpreter.stubs(:room_loader).returns(@room_loader)
    room = ["-", "2", "Alternative 1", "123", "Alternative 2", "234"].extend(Room)
    @alternatives = Alternatives.parse?(room.current, room, @enterpreter)
    room = ["+", "1", "Alternative", "345", "CONDITION"].extend(Room)
    @conditional_alternatives = Alternatives.parse?(room.current, room, @enterpreter)
  end

  def test_should_build_code
    assert_equal(expected_code_for_alternatives, @alternatives.code)
    assert_equal(expected_code_for_conditional_alternatives, @conditional_alternatives.code)
  end

  def test_should_always_be_at_end_of_room_or_block
    room = ["+", "1", "Alternative", "345", "CONDITION", "should not be here"].extend(Room)
    assert_raise(RuntimeError) { Alternatives.parse?(room.current, room, @enterpreter) }
    room = ["+", "1", "Alternative", "345", "CONDITION", "}"].extend(Room)
    assert_nothing_raised(RuntimeError) { Alternatives.parse?(room.current, room, @enterpreter) }
  end

  def test_should_escape_quotation_marks
    room = ['-', '1', 'I say "Hello"', '123'].extend(Room)
    assert_equal(expected_code_for_quotations_in_alternatives, Alternatives.parse?(room.current, room, @enterpreter).code)
  end

  def test_should_not_freak_out_over_a_cancelled_procedure_call
    room = ['-', '}'].extend(Room) # this is a way to quickly exit a procedure call
    assert_equal('return true;', Alternatives.parse?(room.current, room, @enterpreter).code)
  end

  def test_should_not_include_alternatives_to_nonexistant_rooms
    room = ["+", "3", "Alternative 1", "123", "-", "Nonexitant room alt", "333", "-", "Alternative 2", "234", "-"].extend(Room)
    @room_loader.stubs(:room_exists?).returns(true, false, true).then.raises("too many calls to room_exists")
    assert_equal(expected_code_for_alternatives, Alternatives.parse?(room.current, room, @enterpreter).code)
  end

  def test_should_insert_player_name_in_alternative_text
    room = ['-', '1', 'My name is <navn>!', '123'].extend(Room)
    assert_equal(expected_code_for_name_in_alternatives, Alternatives.parse?(room.current, room, @enterpreter).code)
  end

  private

  def expected_code_for_name_in_alternatives
    ['$visible_alternatives = 0;',
     'if ($this->con(!$this->receiver->has_flag("nr123"))) { $this->receiver->add_alternative("My name is ".$this->receiver->get_nickname()."!", 123); $visible_alternatives++; }',
     'return;']
  end
  
  def expected_code_for_alternatives
    ['$visible_alternatives = 0;',
     'if ($this->con(!$this->receiver->has_flag("nr123"))) { $this->receiver->add_alternative("Alternative 1", 123); $visible_alternatives++; }',
     'if ($this->con(!$this->receiver->has_flag("nr234"))) { $this->receiver->add_alternative("Alternative 2", 234); $visible_alternatives++; }',
     'return;']
  end

  def expected_code_for_conditional_alternatives
    ['$visible_alternatives = 0;',
     'if ($this->con($this->receiver->has_flag("CONDITION"))) {',
     '  if ($this->con(!$this->receiver->has_flag("nr345"))) { $this->receiver->add_alternative("Alternative", 345); $visible_alternatives++; }',
     '}',
     'return;']
  end

  def expected_code_for_quotations_in_alternatives
    ['$visible_alternatives = 0;',
     'if ($this->con(!$this->receiver->has_flag("nr123"))) { $this->receiver->add_alternative("I say \"Hello\"", 123); $visible_alternatives++; }',
     'return;']
  end

end