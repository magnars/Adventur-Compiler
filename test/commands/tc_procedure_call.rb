require 'test/unit'
require 'rubygems'
require 'mocha'
require 'commands/procedure_call'
require 'room'

class CommandsProcedureCallTestCase < Test::Unit::TestCase

  def test_should_generate_code
    room = ['(@)23', 'should not show'].extend(Room)
    room.number = 17
    @room23 = ['contents', 'contents', '-', '1', 'alternative', '123'].extend(Room)
    room_loader = mock('room_loader')
    room_loader.expects(:get).with(23).returns(@room23)
    enterpreter = mock('enterpreter')
    enterpreter.stubs(:room_loader).returns(room_loader)
    enterpreter.expects(:current_command).with(@room23).returns(@contents = mock('contents')).times(2)
    @contents.stubs(:contents).returns("contents")
    enterpreter.stubs(:has_function).returns(false)
    enterpreter.expects(:register_function).with("procedure_call_to_23")
    ProcedureCall::ReturnFromProcedureCall.stubs(:new).returns(ret = mock('return'))
    ret.stubs(:code).returns([])
    enterpreter.expects(:define_function).with("procedure_call_to_23", [@contents, @contents, ret])
    @procedure = ProcedureCall.parse?(room.current, room, enterpreter)    
    @contents.stubs(:code).returns("$this->receiver->code();")
    assert_equal(expected_code, @procedure.code)
  end

  def test_should_return_from_procedure_call_with_true
    ret = ProcedureCall::ReturnFromProcedureCall.new
    assert_equal('return true;', ret.code)
  end

  private
  
  def expected_code
    ['$this->receiver->room_number_changed(23);',
     '$continue = $this->procedure_call_to_23();',
     'if ($this->con(!$continue)) { return; }',
     '$this->receiver->room_number_changed(17);']
  end

end