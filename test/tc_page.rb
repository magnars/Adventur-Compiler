require 'test/unit'
require 'rubygems'
require 'mocha'
require 'page'

class PageTestCase < Test::Unit::TestCase

  def setup
    room_loader = mock('room_loader')
    Enterpreter.expects(:new).with(0, room_loader, nil).returns(enterpreter = mock('enterpreter'))
    enterpreter.expects(:enterpret).returns("public function execute() {\n  $this->receiver->code();\n}")
    @page = Page.new(0, room_loader, nil)
  end

  def test_should_base_identifier_on_starting_room_and_page_code_hash
    assert_equal("0_87002840", @page.identifier)
  end

  def test_should_generate_page_code
    assert_equal(expected_code, @page.code)
  end

  def test_should_give_nice_error_messages
    error = assert_raise(RuntimeError) { Page.new(1234, nil, nil) }
    assert_match(/room 1234/, error.message)
    assert_match(/expected exactly once/, error.message)
    assert_match(/none/, error.message)
  end

  private

  def expected_code
    <<-CODE
<?php
class PageInstance {
  private $receiver;
  public static function version() { return '0_87002840'; }
  public function __construct($receiver) { $this->receiver = $receiver; }
  public function execute() {
    $this->receiver->code();
  }
  private function con($bool) { return $this->receiver->conditional($bool); }
}
?>
CODE
  end

end
