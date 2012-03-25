require 'test/unit'
require 'rubygems'
require 'mocha'
require 'room'
require 'commands/plain_text'
require 'commands/conditional_goto'

class CommandsConditionalGotoTestCase < Test::Unit::TestCase

  def test_should_jump_on_conditional
    command = setup_jump_mocks ['[@]623', 'REQUIREMENT', 'should not show'].extend(Room)
    assert_equal(expected_code_for_normal_jump, command.code)
  end

  def test_should_jump_on_visit_count
    room = ['[X]3', '623'].extend(Room)
    room.number = 453
    command = setup_jump_mocks room
    assert_equal(expected_code_for_jump_on_visit_count, command.code)
  end
  
  def test_should_add_implicit_requirement_when_no_requirements
    command = setup_jump_mocks ['[@]623', '-'].extend(Room)
    assert_equal(expected_code_for_nonrequirement_jump, command.code)
  end
  
  private

  def setup_jump_mocks(room)
    enterpreter = mock('enterpreter')
    enterpreter.expects(:parse).with(623).returns([PlainText.new("contents")])
    enterpreter.stubs(:has_function).returns(false)
    enterpreter.stubs(:register_function)
    enterpreter.stubs(:define_function)
    ConditionalGoto.parse?(room.current, room, enterpreter)
  end
  
  def expected_code_for_normal_jump
    [
      'if ($this->con((!($this->receiver->has_flag("nr623")) && $this->receiver->has_flag("REQUIREMENT")))) {',
      '  $this->receiver->room_number_changed(623);', 
      '  $this->execute_room_623();', 
      '  return;',
      '}'
    ]
  end

  def expected_code_for_nonrequirement_jump
    [
      'if ($this->con(!($this->receiver->has_flag("nr623")))) {',
      '  $this->receiver->room_number_changed(623);', 
      '  $this->execute_room_623();', 
      '  return;',
      '}'
    ]
  end

  def expected_code_for_jump_on_visit_count
    [
      'if ($this->con($this->receiver->get_detail("\$_VISITS_TO_453") == 3)) {',
      '  $this->receiver->room_number_changed(623);', 
      '  $this->execute_room_623();', 
      '  return;',
      '}'
    ]
  end

end