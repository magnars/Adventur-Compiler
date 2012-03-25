require 'room'

# For å lagre den massive jobben det er å finne alle kandidater, holder det å:
# - lagre @all_candidates, som er en map  room_number => [candidate, candidate]  <int, array(int)>
# - kjenne alle origins slik at den reindekserer dersom en origin er endret

# Jeg trodde det var dette som tok lang tid .. det var helt feil, den bruker 6-7 sek på starten
# og så er den ferdig.. ingen grunn til å cache dette. Hovedmengden med tid brukes på å kompilere
# alle rommene.. (sekundært: det tar litt tid å finne alle de linkede rommene)

# !!!    Størst besparing er helt klart å bare kompilere de rommene som er endret eller nye
#           - da blir en full scan av alle links unødvendig
#           - da blir en full rekompilering unødvendig

# det er rett og slett kun all.rb som skal byttes ut.. på tide å dra den inn i testcase-varmen?

class TimedJumpCoordinator
  def initialize(room_loader)
    @room_loader = room_loader
  end

  def candidates_for(room_number)
    (candidates = find_candidates[room_number.to_i]) ? candidates.sort.uniq : []
  end

  def jump_candidates_for(room_number)
    (candidates = find_candidates[room_number.to_i]) ? generate_code_for(candidates.sort.uniq) : []
  end

  def generate_code_for(candidates)
    code = [
      '[!]$_CALL_DELAY > 0',
      '{',
      '$_CALL_DELAY--',
    ]
    candidates.each do |number|
      code << "[!]+17$_CALL_DELAY == 0$_DELAYED_CALL == #{number}"
      code << "(@)#{number}"
    end
    code << '}'
    code
  end

  def find_candidates
    @all_candidates || find_all_candidates
  end


  # dict: decal = et utsatt prosedyrekall
  #       executer = et rom som kanskje kjører en decal
  #       origin = et rom som starter en decal
  #       target = prosedyrerommet som kalles etter delayen
  #       candidate = en decal som kanskje skal kjøres i et gitt rom

  def find_all_candidates
    @all_candidates = {}
    @unhandled_in_a_row = 0
    unhandled_decalls = all_decalls.clone
    while unhandled_decalls.size > 0
      decall = unhandled_decalls.shift
      if unhandled_decalls.any? { |unhandled| decall.origin == unhandled.target } then
        unhandled_decalls.push decall
        @unhandled_in_a_row = @unhandled_in_a_row + 1
        if @unhandled_in_a_row > 1000
          raise "Too many unhandled decalls in a row"
        end
      else
        handle decall
        @unhandled_in_a_row = 0
      end
    end
    @all_candidates
  end

  def handle(decall)
    origins = ([decall.origin] + procedure_callers(decall.origin) + chained_origins(decall)).sort.uniq
    decall_executers = origins.map { |origin| find_executers_for(origin, decall.delay) }.flatten.sort.uniq
    decall_executers.each do |executer|
      (@all_candidates[executer] ||= []) << decall.target
      decall.add_executer(executer)
    end
  end

  def chained_origins(me)
    all_decalls.select { |parent| parent.target == me.origin }.map { |parent| parent.executers }.flatten
  end

  def procedure_callers(procedure)
    all_procedure_calls.select { |pc| pc.procedure == procedure }.map { |pc| pc.caller }
  end

  def find_executers_for(origin, delay)
    if delay == 0 then
      []
    else
      refs = (room_references_in(origin) - [0, 115]) # don't move into starting room or death room
      (refs + refs.map {|reference| find_executers_for(reference, delay - 1) }).flatten.sort.uniq
    end
  end

  # -------------------------------------------------------------#

  def all_procedure_calls
    @all_procedure_calls ||= find_all_procedure_calls
  end

  def find_all_procedure_calls
    procedure_calls = []
    @room_loader.all_room_numbers.each do |caller|
      load_room(caller).join("\n").scan(/^\(@\)([^\n]+)/m).each do |procedure|
        procedure_calls << ProcedureCall.new(caller, procedure.first.to_i)
      end
    end
    procedure_calls
  end

  class ProcedureCall
    attr_reader :caller, :procedure
    def initialize(caller, procedure)
      @caller, @procedure = caller, procedure
    end
  end

  def all_decalls
    @all_decalls ||= find_all_decalls
  end

  def find_all_decalls
    decalls = []
    @room_loader.all_room_numbers.each do |origin|
      load_room(origin).join("\n").scan(/^\{\}([^\n]+)\n([^\n]+)/m).each do |delay, target|
        decalls << Decall.new(target.to_i, delay.to_i, origin)
      end
    end
    decalls
  end

  class Decall
    attr_reader :target, :delay, :origin, :executers
    
    def initialize(target, delay, origin)
      @target = target
      @delay = delay
      @origin = origin
      @executers = []
    end
    
    def add_executer(executer)
      @executers << executer
    end
    
    # def to_s
    #   "<Decall: Call #{target} after #{delay} steps from #{origin}>"
    # end
    
  end

  def room_references_in(number)
    room = load_room(number)
    room.map! { |line| line =~ /^\(@\)(\d+)/ ? room_without_alternatives($1) : line }
    room.flatten! # adding procedure calls to room body
    joined = room.join("\n")
    my_jumps = (joined.scan(/^@(\d+)/m) + joined.scan(/^\[@\](\d+)/m) + joined.scan(/^\[X\][^\n]+\n(\d+)/m)).flatten
    my_alternatives = references_in_alternatives_in(room)
    other_alternatives = joined.scan(/^\{@\}(\d+)/m).map { |number| references_in_alternatives_in(load_room(number.first)) }
    (my_jumps + my_alternatives + other_alternatives).flatten.map { |s| s.to_i }
  end

  def references_in_alternatives_in(room)
    refs = []
    while room.current do
      if room.current === "-" then
        alts = room.next.to_i
        alts.times { room.next; refs << room.next.strip }
      elsif room.current === "+" then
        alts = room.next.to_i
        alts.times { room.next; refs << room.next.strip; room.next }
      end
      room.next
    end
    refs
  end

  def room_without_alternatives(number)
    load_room(number).select { |line| alternatives_reached ||= line =~ /^(\-|\+)$/; ! alternatives_reached }
  end

  def load_room(number)
    @room_loader.room_exists?(number) ? @room_loader.get(number) : empty_room(number)
  end

  def empty_room(number)
    r = [].extend Room
    r.number = number
    r
  end

end