require 'commands/plain_text'
require 'commands/add_flag'
require 'commands/remove_flag'
require 'commands/conditional_command'
require 'commands/if_statement'
require 'commands/alternatives'
require 'commands/goto_room'
require 'commands/alternatives_from_other'
require 'commands/procedure_call'
require 'commands/save_command'
require 'commands/run_saved_command'
require 'commands/end_paragraph'
require 'commands/add_deed'
require 'commands/add_kongerupi'
require 'commands/remove_alternatives'
require 'commands/assign_to_variable'
require 'commands/reinstate_alternatives'
require 'commands/conditional_goto'
require 'commands/count_visits'
require 'commands/activate_saving'
require 'commands/unfinished_story'
require 'commands/unreachable'
require 'commands/end_subpage'
require 'commands/increase_bodycount'
require 'commands/add_timejump'
require 'commands/sentence_with_variable'
require 'commands/summarize_deeds'
require 'commands/register_delayed_call'
require 'enumerator'
require 'hashcode_keeper'
require 'timed_jump_coordinator'

class Enterpreter
  attr_reader :room_loader

  def self.command_types
    [
     SaveCommand,
     RunSavedCommand,
     GotoRoom,
     ConditionalGoto,
     ProcedureCall,
     CountVisits,
     AssignToVariable,
     AlternativesFromOther,
     Alternatives,
     RemoveAlternatives,
     ReinstateAlternatives,
     IfStatement,
     ConditionalCommand,
     RemoveFlag, AddFlag,
     AddKongerupi,
     ActivateSaving,
     UnfinishedStory,
     Unreachable,
     DramaticPause,
     IncreaseBodycount,
     SummarizeDeeds,
     RegisterDelayedCall,
     AddTimejump,
     AddDeed,
     EndParagraph,
     SentenceWithVariable,
     PlainText
    ]
  end

  def initialize(room_number, room_loader, timed_jump_coordinator)
    @room_loader, @room_number, @timed_jump_coordinator = room_loader, room_number, timed_jump_coordinator
    @functions = []
  end

  def enterpret()
    code_for(parse(@room_number))
  end

  def parse(room_number)
    room = @room_loader.get(room_number)
    room.unshift(@timed_jump_coordinator.jump_candidates_for(room_number)).flatten!
    commands = []
    begin
      commands << current_command(room)
    end while room.next
    commands
  end

  def current_command(room)
    prevl = room.index == 0 ? "<bof>" : room[room.index-1]
    line = room.current
    nextl = room.peek or "<eof>"
    begin
      self.class.command_types.inject(false) do |command, type|
        command = type.parse?(room.current.clone, room, self) and break command
      end
    rescue
      raise ["",
             "--------------------------------------------------------------",
             " Error while parsing in room #{room.number}:",
             " Stumbled on line:",
             "     #{prevl}",
             " --> #{line}",
             "     #{nextl}",
             " Message: #{$!}",
             "--------------------------------------------------------------"
            ].join("\n")
    end
  end

  def register_function(name)
    @functions << Function.new(name, [])
  end

  def define_function(name, commands)
    @functions.find { |f| f.name === name }.commands = commands
  end

  def has_function(name)
    !! @functions.find { |f| f.name === name }
  end

  def hashcode_keeper
    @@hashcode_keeper ||= initialize_hashcode_keeper
  end

  def self.reset_hashcode_keeper
    @@hashcode_keeper = nil
  end

  private

  def initialize_hashcode_keeper
    filename = "#{File.dirname(__FILE__)}/../resources/hashcodefile.txt"
    keeper = HashcodeKeeper.new IO.readlines(filename)
    saved_command_regexp = /^([^\n ]+) => ([^\n]+)$/
    deed_regexp = /^(:snill|:slem) => ([^\n]+)$/
    @room_loader.all_room_numbers.each do |number|
      room_contents = @room_loader.get(number).join("\n")
      room_contents.scan(saved_command_regexp).each {|key, command| keeper.add(key, command) }
      room_contents.scan(deed_regexp).each { |type, description| keeper.add((type === ":slem" ? "_EVIL_DEED" : "_GOOD_DEED"), description) }
    end
    keeper.save(filename)
    keeper
  end

  def code_for(commands)
    code_skeleton.gsub(":ROOMNUMBER:", @room_number.to_s).gsub(":COMMANDS:", indented_commands(commands)).gsub(":FUNCTIONS:", @functions.map { |f| ["private function #{f.name}() {", indented_commands(f.commands), "}"] }.flatten.join("\n"))
  end

  def indented_commands(commands)
    commands.map { |c| c.code }.flatten.map { |line| "  #{line}" }.join("\n")
  end

  class Function
    attr_reader :name
    attr_accessor :commands
    def initialize(name, commands)
      @name, @commands = name, commands
    end
  end

  def code_skeleton
    <<-CODE
public function execute() {
  $this->receiver->room_number_changed(:ROOMNUMBER:);
:COMMANDS:
}
:FUNCTIONS:
CODE
  end

end
