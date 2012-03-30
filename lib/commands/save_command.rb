# -*- coding: utf-8 -*-
class SaveCommand
  def initialize(name, contents, hashcode_keeper)
    @name, @contents, @contents_hash = name, contents, hashcode_keeper.code_for(name, contents)
  end

  def self.parse?(line, room = nil, enterpreter = nil)
    if line =~ /^([A-ZÆØÅ_.-]+) => (.+)$/
      new $1, $2, enterpreter.hashcode_keeper
    else
      false
    end
  end

  def code
    "$this->receiver->set_detail(\"]C[#{@name}\", \"#{@contents_hash}\");"
  end

end
