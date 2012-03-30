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
  end

  def test_should_parse_alternatives
    room = ["=", "Alternative 1", "@123", "Alternative 2", "@234"].extend(Room)
    alternatives = Alternatives.parse?(room.current, room, @enterpreter)
    assert_equal(expected_code_for_alternatives, alternatives.code)
  end

  def test_should_allow_blank_lines
    room = ["=", "Alternative 1", "@123", "", "Alternative 2", "@234", ""].extend(Room)
    alternatives = Alternatives.parse?(room.current, room, @enterpreter)
    assert_equal(expected_code_for_alternatives, alternatives.code)
  end

  def test_should_quit_when_reaching_block_end
    room = ["=", "Alternative 1", "@123", "", "Alternative 2", "@234", "", "}", "more stuff"].extend(Room)
    alternatives = Alternatives.parse?(room.current, room, @enterpreter)
    assert_equal(expected_code_for_alternatives, alternatives.code)
  end

  def test_should_parse_multiline_alternative_texts
    room = ["=", "This alternative", "consists of multiple", "lines", " @123", "", "This one", "too", "@234"].extend(Room)
    alternatives = Alternatives.parse?(room.current, room, @enterpreter)
    assert_equal(expected_code_for_multiline_alternatives, alternatives.code)
  end

  def test_should_parse_alternative_with_conditionals
    room = ["=", "Alternative", "@345 ? CONDITION"].extend(Room)
    conditional_alternatives = Alternatives.parse?(room.current, room, @enterpreter)
    assert_equal(expected_code_for_conditional_alternatives, conditional_alternatives.code)
  end

  def test_should_always_be_at_end_of_room
    room = ["=", "Alternative", "@345 ? CONDITION", "should not be here"].extend(Room)
    assert_raise(RuntimeError) { Alternatives.parse?(room.current, room, @enterpreter) }
  end

  def test_should_escape_quotation_marks
    room = ['=', 'I say "Hello"', '@123'].extend(Room)
    assert_equal(expected_code_for_quotations_in_alternatives, Alternatives.parse?(room.current, room, @enterpreter).code)
  end

  def test_should_not_include_alternatives_to_nonexistant_rooms
    room = ["=", "Alternative 1", "@123", "Nonexitant room alt", "@333", "Alternative 2", "@234"].extend(Room)
    @room_loader.stubs(:room_exists?).returns(true, false, true).then.raises("too many calls to room_exists")
    assert_equal(expected_code_for_alternatives, Alternatives.parse?(room.current, room, @enterpreter).code)
  end

  def test_should_not_include_alternatives_to_nonexistant_rooms
    room = ["=", "Alternative 1", "@123", "Nonexitant room alt", "@-1", "Alternative 2", "@234"].extend(Room)
    @room_loader.stubs(:room_exists?).returns(true, false, true).then.raises("too many calls to room_exists")
    assert_equal(expected_code_for_alternatives, Alternatives.parse?(room.current, room, @enterpreter).code)
  end

  def test_should_insert_player_name_in_alternative_text
    room = ['=', 'My name is <navn>!', '@123'].extend(Room)
    assert_equal(expected_code_for_name_in_alternatives, Alternatives.parse?(room.current, room, @enterpreter).code)
  end

  def test_should_not_freak_out_over_a_cancelled_procedure_call
    room = ['='].extend(Room) # this is a way to quickly exit a procedure call
    assert_equal('return true;', Alternatives.parse?(room.current, room, @enterpreter).code)
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

  def expected_code_for_multiline_alternatives
    ['$visible_alternatives = 0;',
     'if ($this->con(!$this->receiver->has_flag("nr123"))) { $this->receiver->add_alternative("This alternative consists of multiple lines", 123); $visible_alternatives++; }',
     'if ($this->con(!$this->receiver->has_flag("nr234"))) { $this->receiver->add_alternative("This one too", 234); $visible_alternatives++; }',
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
