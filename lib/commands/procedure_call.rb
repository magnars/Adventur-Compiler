class ProcedureCall

  def initialize(room_number, procedure_number)
    @room_number, @procedure_number = room_number, procedure_number
  end

  def self.parse?(line, room = nil, enterpreter = nil)
    if line =~ /^\(@\)(\d+)$/
      procedure_number = $1.to_i
      unless enterpreter.has_function("procedure_call_to_#{procedure_number}")
        enterpreter.register_function("procedure_call_to_#{procedure_number}")
        procedure = enterpreter.room_loader.get(procedure_number)
        commands = []
        until procedure.current == "=" or procedure.current == nil
          commands << enterpreter.current_command(procedure)
          procedure.next
        end
        commands << ReturnFromProcedureCall.new
        enterpreter.define_function("procedure_call_to_#{procedure_number}", commands)
      end
      new room.number, procedure_number
    else
      false
    end
  end

  def code
    ["$this->receiver->room_number_changed(#{@procedure_number});",
     "$continue = $this->procedure_call_to_#{@procedure_number}();",
     "if ($this->con(!$continue)) { return; }",
     "$this->receiver->room_number_changed(#{@room_number});"].flatten
  end

  class ReturnFromProcedureCall
    def code
      "return true;"
    end
  end

end
