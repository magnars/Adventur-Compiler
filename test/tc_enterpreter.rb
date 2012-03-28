# -*- coding: utf-8 -*-
require 'test/unit'
require 'rubygems'
require 'mocha'
require 'enterpreter'
require 'room'
require 'commands/plain_text'

class EnterpreterTestCase < Test::Unit::TestCase

  def setup
    @room_loader = mock('room_loader')
    (@tjump = mock('timed jump coordinator')).stubs(:jump_candidates_for).returns([])
    Enterpreter.reset_hashcode_keeper
    @hashcode_keeper = HashcodeKeeper.new
    HashcodeKeeper.stubs(:new).returns(@hashcode_keeper)
    @enterpreter = Enterpreter.new(0, @room_loader, @tjump)
  end

  def test_should_parse_multiple_lines
    mock_room(["line1", "line2", "line3"])
    assert_equal(3, @enterpreter.parse(0).size)
  end

  def test_should_return_code
    mock_room(["line1", "line2", "line3"])
    assert_equal(expected_code_for_three_lines, @enterpreter.enterpret)
  end

  def test_should_properly_indent_multiline_code_from_commands
    mock_room(["line1", "line2 ? TEST", "line3"])
    assert_equal(expected_code_for_conditional, @enterpreter.enterpret)
  end

  def test_should_allow_registering_and_definition_of_functions
    mock_room(["line1", "line2", "line3"])
    @enterpreter.register_function("procedure_call_to_531")
    @enterpreter.define_function("procedure_call_to_531", [PlainText.new("line4")])
    assert_equal(expected_code_for_added_functions, @enterpreter.enterpret)
  end

  def test_should_allow_checking_if_a_function_exists
    assert(!@enterpreter.has_function("alternatives_from_844"), "should not have function yet")
    @enterpreter.register_function("alternatives_from_844")
    assert(@enterpreter.has_function("alternatives_from_844"), "should have function now")
  end

  def test_should_find_all_unqiue_lines_for_a_C_command
    @room_loader.expects(:all_room_numbers).returns([1]).times(1)
    mock_room(["line1", "]C[TEST", "contents", "line2"])
    @hashcode_keeper.expects(:add).with("TEST", "contents")
    @hashcode_keeper.expects(:save)
    assert_equal @hashcode_keeper, @enterpreter.hashcode_keeper
    assert_equal @hashcode_keeper, @enterpreter.hashcode_keeper # test cache
  end

  def test_should_find_multiple_C_command_lines_in_one_room
    @room_loader.expects(:all_room_numbers).returns([1])
    mock_room(["line1", "]C[TEST", "contents", "line2", "]C[TEST", "contents2", "line3"])
    @hashcode_keeper.expects(:save)
    assert_equal @hashcode_keeper, @enterpreter.hashcode_keeper
    assert_equal 2, (list = @hashcode_keeper.contentlist_for("TEST")).size
    assert_equal "contents", list.first.text
    assert_equal "contents2", list.last.text
  end

  def test_should_find_good_and_evil_deeds
    @room_loader.expects(:all_room_numbers).returns([1])
    mock_room(["Hei", "---", '"Slemt altså"', "Hallo", "+++", "Snilt også", "+++", "Mer snilt", "+++", "Mer snilt", "Hadet"])
    @hashcode_keeper.expects(:save)
    assert_equal @hashcode_keeper, @enterpreter.hashcode_keeper
    assert_equal 1, (list = @hashcode_keeper.contentlist_for("_EVIL_DEED")).size
    assert_equal '"Slemt altså"', list.first.text
    assert_equal 2, (list = @hashcode_keeper.contentlist_for("_GOOD_DEED")).size
    assert_equal "Snilt også", list.first.text
    assert_equal "Mer snilt", list.last.text
  end

  def test_should_not_change_original_line
    room = ['()KARDEMOMME'].extend(Room)
    @enterpreter.current_command(room)
    assert_equal('()KARDEMOMME', room.first)
  end

  private

  def mock_room(lines)
    @room_loader.stubs(:get).returns(lines.extend(Room))
  end

  def expected_code_for_three_lines
    <<-EXPECTED
public function execute() {
  $this->receiver->room_number_changed(0);
  $this->receiver->write("line1");
  $this->receiver->write("line2");
  $this->receiver->write("line3");
}

EXPECTED
  end

  def expected_code_for_conditional
    <<-EXPECTED
public function execute() {
  $this->receiver->room_number_changed(0);
  $this->receiver->write("line1");
  if ($this->con($this->receiver->has_flag("TEST"))) {
    $this->receiver->write("line2");
  }
  $this->receiver->write("line3");
}

EXPECTED
  end

  def expected_code_for_added_functions
    <<-EXPECTED
public function execute() {
  $this->receiver->room_number_changed(0);
  $this->receiver->write("line1");
  $this->receiver->write("line2");
  $this->receiver->write("line3");
}
private function procedure_call_to_531() {
  $this->receiver->write("line4");
}
EXPECTED
  end

end
