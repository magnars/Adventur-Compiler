<?php
class PageInstance {
  private $receiver;
  public static function version() { return '1_-675873966'; }
  public function __construct($receiver) { $this->receiver = $receiver; }
  public function execute() {
    $this->receiver->room_number_changed(1);
    $this->receiver->write("Du vandrer inn blant den store mengden flyktninger som har søkt tilflukt her");
    $this->receiver->write("utenfor katedralen. Mange er skadd. De har dårlig med tepper, dårlig med");
    $this->receiver->write("bandasjer, og dårlig med mat. Du ser en og annen kirketjener som gjør sitt beste");
    $this->receiver->write("for å hjelpe, men de er for få.");
    if ($this->con($this->receiver->has_flag("\$MAT"))) { $this->receiver->remove_flag("\$MAT"); }
    if ($this->con($this->receiver->has_flag("EPLE"))) {
      $this->receiver->add_to_detail("\$MAT", 1);
    }
    if ($this->con($this->receiver->has_flag("FISK"))) {
      $this->receiver->add_to_detail("\$MAT", 1);
    }
    if ($this->con($this->receiver->has_flag("PØLSE"))) {
      $this->receiver->add_to_detail("\$MAT", 1);
    }
    if ($this->con($this->receiver->has_flag("GAMMELOST"))) {
      $this->receiver->add_to_detail("\$MAT", 1);
    }
    if ($this->con($this->receiver->has_flag("BANANER"))) {
      $this->receiver->add_to_detail("\$MAT", 1);
    }
    if ($this->con($this->receiver->has_flag("VANNMELON"))) {
      $this->receiver->add_to_detail("\$MAT", 1);
    }
    $visible_alternatives = 0;
    if ($this->con($this->receiver->has_flag("HEALINGSKROLL"))) {
      if ($this->con(!$this->receiver->has_flag("nr3"))) { $this->receiver->add_alternative("Jeg helbreder en kar med store brannskader med min healingskroll.", 3); $visible_alternatives++; }
    }
    if ($this->con($this->receiver->get_detail("\$MAT") >= 2)) {
      if ($this->con(!$this->receiver->has_flag("nr4"))) { $this->receiver->add_alternative("Jeg deler ut litt mat til de sultne.", 4); $visible_alternatives++; }
    }
    if ($this->con(!((!($this->receiver->has_flag("POSEMEDSMULTRINGER")) && !($this->receiver->has_flag("MARIEKJEKS")))))) {
      if ($this->con(!$this->receiver->has_flag("nr5"))) { $this->receiver->add_alternative("Jeg muntrer opp barna med noen søtsaker.", 5); $visible_alternatives++; }
    }
    if ($this->con($this->receiver->has_flag("HAR-HJULPET-FLYKTNINGER"))) {
      if ($this->con(!$this->receiver->has_flag("nr7"))) { $this->receiver->add_alternative("Jeg ser om jeg finner en kirketjener, og spør hva mer jeg kan gjøre.", 7); $visible_alternatives++; }
    }
    if ($this->con(!(($this->receiver->has_flag("HAR-HJULPET-FLYKTNINGER") && !($visible_alternatives <= 1))))) {
      if ($this->con(!$this->receiver->has_flag("nr6"))) { $this->receiver->add_alternative("Det er ikke noe jeg kan gjøre for å hjelpe til, så jeg går.", 6); $visible_alternatives++; }
    }
    return;
  }
  

  private function con($bool) { return $this->receiver->conditional($bool); }
}
?>
