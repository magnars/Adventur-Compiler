require 'test/unit'
require 'timed_jump_coordinator'
require 'room'

class TimedJumpCoordinatorTestCase < Test::Unit::TestCase

  def setup
    @rooms = MockRoomLoader.new
    @coordinator = TimedJumpCoordinator.new @rooms
  end

  def test_should_return_empty_array_when_no_candidates
    @rooms.add 0, ['{}0', '199', '@1']
    assert_candidates_for_executor([], 1)
  end

  def test_should_find_candidates_after_regular_jumps
    @rooms.add 0, ['{}1', '199', '@1']
    assert_candidates_for_executor([199], 1)
  end

  def test_should_find_candidates_after_conditional_jumps
    @rooms.add 0, ['{}1', '199', '[@]1', 'REQ', '[@]2', 'UIR']
    assert_candidates_for_executor([199], 1)
    assert_candidates_for_executor([199], 2)
  end

  def test_should_find_candidates_after_jump_on_visit_count
    @rooms.add 0, ['{}1', '199', '[X]3', '1']
    assert_candidates_for_executor([199], 1)
  end

  def test_should_find_candidates_after_alternatives_without_reqs
    @rooms.add 0, ['{}1', '199', '-', '2', 'Alternativ 1', '1', 'Alternativ 2', '2']
    assert_candidates_for_executor([199], 1)
    assert_candidates_for_executor([199], 2)
  end

  def test_should_find_candidates_after_alternatives_with_reqs
    @rooms.add 0, ['{}1', '199', '+', '2', 'Alternativ 1', '1', 'REQ', 'Alternativ 2', '2', '-']
    assert_candidates_for_executor([199], 1)
    assert_candidates_for_executor([199], 2)
  end

  def test_should_find_candidates_from_other_rooms_alternatives
    @rooms.add 0, ['{}1', '199', '{@}1']
    @rooms.add 1, ['Candidate', '+', '2', 'Alternativ 1', '1', 'REQ', 'Alternativ 2', '2', '-']
    assert_candidates_for_executor([199], 1)
    assert_candidates_for_executor([199], 2)
  end

  def test_should_find_candidates_from_jumps_in_procedure_calls
    @rooms.add 0, ['{}1', '199', '(@)1']
    @rooms.add 1, ['Candidate', '[@]155', 'FLAG', '+', '2', 'Alternativ 1', '1', 'REQ', 'Alternativ 2', '2', '-']
    assert_candidates_for_executor([199], 155)
    assert_candidates_for_executor([], 1)
    assert_candidates_for_executor([], 2)
  end

  def test_should_use_delay_declarations_from_procedure_calls
    @rooms.add 0, ['(@)1', '+', '2', 'Alternativ 1', '1', 'REQ', 'Alternativ 2', '2', '-']
    @rooms.add 1, ['{}1', '199']
    assert_candidates_for_executor([199], 1)
    assert_candidates_for_executor([199], 2)
  end

  def test_should_find_candidates_on_deeper_levels
    @rooms.add 0, ['{}2', '199', '@1']
    @rooms.add 1, ['@2']
    @rooms.add 2, ['@3']
    assert_candidates_for_executor([199], 1)
    assert_candidates_for_executor([199], 2)
    assert_candidates_for_executor([], 3)
  end

  def test_should_support_multiple_jumps
    @rooms.add 0, ['{}1', '844', '{}2', '199', '@1']
    @rooms.add 1, ['@2']
    assert_candidates_for_executor([199, 844], 1)
    assert_candidates_for_executor([199], 2)
  end

  def test_should_support_chained_calls
    @rooms.add 0, ['{}1', '199', '@1']
    @rooms.add 1, ['@4']
    @rooms.add 4, ['@5']
    @rooms.add 199, ['{}1', '276']
    assert_candidates_for_executor([199], 1)
    assert_candidates_for_executor([276], 4)
  end

  def test_should_delay_decalls_that_arent_ready
    @rooms.add 199, ['{}1', '276']
    @rooms.add 1000, ['{}1', '199', '@1001']
    @rooms.add 1001, ['@1004']
    @rooms.add 1004, ['@1005']
    assert_candidates_for_executor([199], 1001)
    assert_candidates_for_executor([276], 1004)    
  end
  
  def test_should_complain_about_endless_loops
    @rooms.add 199, ['{}1', '276', '@1004']
    @rooms.add 276, ['{}1', '199', '@1001']
    @rooms.add 1001, ['@1004']
    @rooms.add 1004, ['']
    assert_raise(RuntimeError) { @coordinator.jump_candidates_for(1001) }
  end

  def test_should_not_make_a_big_deal_of_nonexistant_rooms
    @rooms.add 0, ['{}2', '199', '@1']
    assert_candidates_for_executor([199], 1)
  end

  def test_should_generate_code
    @rooms.add 0, ['{}1', '199', '@1']
    assert_equal(expected_code, @coordinator.jump_candidates_for(1))
  end
    
  def expected_code
    [
      '[!]$_CALL_DELAY > 0',
      '{',
      '$_CALL_DELAY--',
      '[!]+17$_CALL_DELAY == 0$_DELAYED_CALL == 199',
      '(@)199',
      '}'
    ]
  end

  def assert_candidates_for_executor(candidates, executor)
    assert_equal(candidates, @coordinator.candidates_for(executor))
  end

  def basic_decall_setup
    @rooms.add 0, dummy_room
    @rooms.add 1, ['{}1', '5', '@3']
    @rooms.add 2, ['{}2', '5', '-', '2', 'Alt3', '3', 'Alt4', '4']
    @rooms.add 3, ['{}1', '7']
    @rooms.add 4, dummy_room
    @rooms.add 5, dummy_room
    @rooms.add 7, ['{}3', '0', 'Text', '{}1', '5', 'More text']
  end

  def dummy_room
    ['Nothing to see here', '-', '2', 'Alt1', '1', 'Alt2', '2']
  end

  def test_should_find_all_procedure_calls
    @rooms.add 0, dummy_room
    @rooms.add 1, ['(@)5']
    @rooms.add 2, ['(@)7', '(@)3']
    @rooms.add 3, ['(@)5']
    @rooms.add 5, ['(@)0']
    @rooms.add 7, ['(@)5']
    procedure_calls = @coordinator.all_procedure_calls
    assert_equal(6, procedure_calls.size)
    assert_equal(3, procedure_calls.select { |call| call.procedure == 5 }.size)
    assert_equal([1, 7, 3], @coordinator.procedure_callers(5))
  end

  def test_should_find_all_decalls
    basic_decall_setup
    decalls = @coordinator.all_decalls
    assert_equal(5, decalls.size)
    assert_equal(3, decalls.select { |decall| decall.target == 5 }.size)
  end
  
  def test_should_find_executers_for_origin_at_a_given_delay
    basic_decall_setup
    assert_equal([], @coordinator.find_executers_for(0, 0))
    assert_equal([1, 2], @coordinator.find_executers_for(0, 1))
    assert_equal([1, 2, 3, 4], @coordinator.find_executers_for(0, 2))
  end
  
  class MockRoomLoader
    
    def initialize
      @rooms = {}
    end
    
    def add(number, lines)
      lines.extend Room
      lines.number = number
      @rooms[number] = lines
    end
    
    def all_room_numbers
      @rooms.keys
    end
    
    def room_exists?(number)
      @rooms.has_key? number.to_i
    end
    
    def get(number)
      number = number.to_i
      raise "tried to get unknown room number #{number} from MockRoomLoader" unless @rooms.has_key? number
      @rooms[number].clone
    end
    
  end

end