require 'test/unit'
require 'rubygems'
require 'mocha'
require 'commands/conditional_command'
require 'commands/plain_text'
require 'room'

class CommandsConditionalCommandTestCase < Test::Unit::TestCase

  def test_should_parse_normal_conditional
    room = ["[!]FLAG", "command", "outside"].extend(Room)
    (enterpreter = mock('enterpreter')).stubs(:current_command).returns(PlainText.new("command"))
    conditional = ConditionalCommand.parse?(room.current, room, enterpreter)
    assert_equal(expected_code, conditional.code)
  end
  
  def test_should_not_add_if_condition_when_always_true
    room = ["[!]-", "command", "outside"].extend(Room)
    (enterpreter = mock('enterpreter')).stubs(:current_command).returns(PlainText.new("command"))    
    conditional = ConditionalCommand.parse?(room.current, room, enterpreter)
    assert_equal('$this->receiver->write("command");', conditional.code)
  end

  def test_should_be_blank_when_always_false
    room = ["[!])(-", "command", "outside"].extend(Room)
    (enterpreter = mock('enterpreter')).stubs(:current_command).returns(PlainText.new("command"))    
    conditional = ConditionalCommand.parse?(room.current, room, enterpreter)
    assert_equal([], conditional.code)    
  end
  
  def test_should_parse_visit_count_conditional
    room = ["[X!]3", "command"].extend(Room)
    room.number = 5244
    (enterpreter = mock('enterpreter')).stubs(:current_command).returns(PlainText.new("command"))    
    conditional = ConditionalCommand.parse?(room.current, room, enterpreter)
    assert_equal(expected_code_for_visit_count, conditional.code)
  end

  private
  
  def expected_code
    ['if ($this->con($this->receiver->has_flag("FLAG"))) {',
     '  $this->receiver->write("command");',
     '}']
  end

  def expected_code_for_visit_count
    ['if ($this->con($this->receiver->get_detail("\$_VISITS_TO_5244") == 3)) {',
     '  $this->receiver->write("command");',
     '}']
  end

end