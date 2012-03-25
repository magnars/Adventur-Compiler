require 'enterpreter'
require 'room_loader'

class Page
  
  def initialize(starting_room, room_loader, timed_jump_coordinator)
    @starting_room = starting_room
    begin
      @code = Enterpreter.new(starting_room, room_loader, timed_jump_coordinator).enterpret
    rescue
      raise [
        "--------------------------------------------------------------",
        " Error while initializing page from room #{@starting_room}!",
        " Message: #{$!}", 
        " Last loaded room number: #{RoomLoader.last_loaded_room_number}",
        "--------------------------------------------------------------"
        ].join("\n")
    end
  end

  def identifier
    "#{@starting_room}_#{@code.hash}"
  end
  
  def code
    code_skeleton.sub(":CODE:", indented_code).sub(":IDENTIFIER:", identifier)
  end
  
  def indented_code
    @code.map { |line| "  #{line}" }.join
  end
  
  private
  
  def code_skeleton
    <<-CODE
<?php
class PageInstance {
  private $receiver;
  public static function version() { return ':IDENTIFIER:'; }
  public function __construct($receiver) { $this->receiver = $receiver; }
:CODE:
  private function con($bool) { return $this->receiver->conditional($bool); }
}
?>
CODE
  end
  
end