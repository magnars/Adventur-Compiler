<?php
class PageInstance {
  private $receiver;
  public static function version() { return '9_-961525309'; }
  public function __construct($receiver) { $this->receiver = $receiver; }
  public function execute() {
    $this->receiver->room_number_changed(9);
    $this->receiver->write("Mannen er for opptatt med å strigråte rundt benet ditt til å legge merke til");
    $this->receiver->write("ditt tilbud om økonomisk støtte.");
    $this->receiver->room_number_changed(8);
    $this->execute_room_8();
    return;
  }
  private function execute_room_8() {
    if ($this->con($this->receiver->has_flag("MARKUS-ER-DØD"))) {
      $this->receiver->write("Etter hvert går hulkingen over, og mannen krøller seg sammen under et teppe.");
      $this->receiver->write("Uten smerter får han endelig sove.");
      $this->receiver->room_number_changed(1);
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
    $this->receiver->write("En annen kar som vandrer omkring og hjelper til kommer bort til dere. \"Jeg så");
    $this->receiver->write("hva du gjorde,\" sier han til deg. \"Det var veldig bra av deg. Jeg heter Markus.\"");
    $this->receiver->write("Markus er en stor blond kar i en skinnende rustning. \"".$this->receiver->get_nickname()."\" sier du. \"Hyggelig");
    $this->receiver->write("å møte deg,\" sier han. Markus har med suppe, og gir den til den gråtende fyren.");
    $this->receiver->write("Han roer seg ned og starter å slurke i seg suppa.");
    if ($this->con(!$this->receiver->has_flag("KJENNER-MARKUS"))) { $this->receiver->add_flag("KJENNER-MARKUS"); }
    if ($this->con(!$this->receiver->has_flag("MØTTE-MARKUS-UTENFOR-KATEDRALEN"))) { $this->receiver->add_flag("MØTTE-MARKUS-UTENFOR-KATEDRALEN"); }
    $visible_alternatives = 0;
    if ($this->con(!$this->receiver->has_flag("nr10"))) { $this->receiver->add_alternative("\"Har du noen idé om hvor ille situasjonen her er?\"", 10); $visible_alternatives++; }
    if ($this->con(!$this->receiver->has_flag("nr10"))) { $this->receiver->add_alternative("\"Hvor mange har blitt hjemløse etter angrepet?\"", 10); $visible_alternatives++; }
    return;
  }

  private function con($bool) { return $this->receiver->conditional($bool); }
}
?>
