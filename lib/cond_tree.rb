# -*- coding: utf-8 -*-
require "conditional"

class CondTree
  def self.parse(s)
    begin
      strip_out_containers(req_parse(replace_with_oldies(s), [:container]))
    rescue
      raise ["",
             "--------------------------------------------------------------",
             " Error while parsing this string:",
             s,
             " Message: #{$!}",
             "--------------------------------------------------------------"
            ].join("\n")
    end
  end

  def self.cons(el, list)
    list.unshift(el)
  end

  def self.size(s)
    s.split(//u).size
  end

  def self.subs(s, from, to = nil)
    cs = s.split(//u)
    return cs[from..-1].join if to.nil?
    cs[from...to].join
  end

  def self.req_parse(s, top)
    return top if (s.empty?)
    return parse_single(s, top) if next_is_single_node(s)
    return [:and, top, parse(subs(s, 4))] if s.start_with? " og "
    return [:or, top, parse(subs(s, 7))] if s.start_with? " eller "
    return [:not_this_without_that, pop_off_not(top), parse(subs(s, 11))] if s.start_with? " uten også "
    return [:this_but_not_that, top, parse(subs(s, 11))] if s.start_with? ", men ikke "
    return [:and, top, parse(subs(s, 6))] if s.start_with? ", men "
    raise "Unable to parse: #{s}"
  end

  def self.parse_single(s, top)
    return parse_value(s, top) if s =~ value_regexp
    return parse_flag(s, top) if s =~ flag_regexp
    return parse_all(s, top) if s =~ all_regexp
    return parse_some(s, top) if s =~ some_regexp
    return parse_parens(s, top) if s.start_with? "("
    return top.push(parse_single(subs(s, 5), [:not])) if s.start_with? "ikke "
    raise "Unable to parse single: #{s}"
  end

  def self.next_is_single_node(s)
    (s =~ value_regexp) or
      (s =~ flag_regexp) or
      (s =~ all_regexp) or
      (s =~ some_regexp) or
      (s.start_with? "(") or
      (s.start_with? "ikke ")
  end

  def self.pop_off_not(top)
    raise "Expected :not, but was #{top[0]}" unless top[0] == :not
      top[1]
  end

  def self.parse_parens(s, top)
    req_parse(subs(s, 1 + find_matching_paren_index(s, 1)),
              top.push(parse(subs(s, 1, find_matching_paren_index(s, 1)))))
  end

  def self.parse_flag(s, top)
    match = get_flag(s)
    req_parse(subs(s, size(match)),
              top.push(match))
  end

  def self.parse_value(s, top)
    match = get_value(s)
    req_parse(subs(s, size(match)),
              top.push(match))
  end

  def self.parse_all(s, top)
    match = get_all(s)
    req_parse(subs(s, size(match)),
              top.push(cons(:all, subs(match, 5).split(/(?:, | og )/))))
  end

  def self.parse_some(s, top)
    match = get_some(s)
    req_parse(subs(s, size(match)),
              top.push(cons(:some, subs(match, 6).split(/(?:, | eller )/))))
  end

  def self.find_matching_paren_index(s, i)
    old_i = i
    cs = s.split(//u)
    num_start = 1
    i = i - 1
    until num_start == 0 do
      i = i + 1
      num_start = num_start + 1 if cs[i] == "("
      num_start = num_start - 1 if cs[i] == ")"
      raise "found no matching paren from #{old_i} in: #{s}" if cs[i].nil?
    end
    i
  end

  def self.strip_out_containers(n)
    return n if n.class == String
    return n if n.class == Symbol
    return strip_out_containers(n[1]) if n[0] == :container
    n.map { |e| strip_out_containers(e) }
  end

  def self.replace_with_oldies(s)
    s = replace_with_old_date(s)
    s = replace_with_old_alt_req(s)
    s = replace_with_old_visits(s)
    replace_neither(s)
  end

  def self.replace_neither(s)
    s = s.gsub("(verken ", "ikke (enten ")
    s.gsub("verken ", "ikke enten ")
  end

  def self.replace_with_old_alt_req(s)
    s.gsub(/(\d)\. alternativ/) { |i| "*#{i.to_i - 1}*" }
  end

  def self.replace_with_old_date(s)
    s.gsub(/den (\d\d)\/(\d\d)/) { "DATO#{$1}#{$2}" }
  end

  def self.replace_with_old_visits(s)
    s.gsub(/(\d+)\. besøk/) { "_BESØK_#{$1}" }
  end

  def self.get_some(s)
    get_leading(":some", some_regexp, s)
  end

  def self.some_regexp()
    /^enten (?:(?:[0-9]+|(?:\$|[nk]r)?[A-ZÆØÅ0-9.*_-]+)(?: (?:[+*\/-<>]|<=|>=|==) (?:[0-9]+|(?:\$|[nk]r)?[A-ZÆØÅ0-9.*_-]+))*(?:, )?)+ eller (?:[0-9]+|(?:\$|[nk]r)?[A-ZÆØÅ0-9.*_-]+)(?: (?:[+*\/-<>]|<=|>=|==) (?:[0-9]+|(?:\$|[nk]r)?[A-ZÆØÅ0-9.*_-]+))*/
  end

  def self.get_all(s)
    get_leading(":all", all_regexp, s)
  end

  def self.all_regexp()
    /^både (?:(?:[0-9]+|(?:\$|[nk]r)?[A-ZÆØÅ0-9.*_-]+)(?: (?:[+*\/-<>]|<=|>=|==) (?:[0-9]+|(?:\$|[nk]r)?[A-ZÆØÅ0-9.*_-]+))*(?:, )?)+ og (?:[0-9]+|(?:\$|[nk]r)?[A-ZÆØÅ0-9.*_-]+)(?: (?:[+*\/-<>]|<=|>=|==) (?:[0-9]+|(?:\$|[nk]r)?[A-ZÆØÅ0-9.*_-]+))*/
  end

  def self.get_value(s)
    get_leading("value", value_regexp, s)
  end

  def self.value_regexp()
    /^(?:[0-9]+|(?:\$|[nk]r)?[A-ZÆØÅ0-9.*_-]+)(?: (?:[+*\/-<>]|<=|>=|==) (?:[0-9]+|(?:\$|[nk]r)?[A-ZÆØÅ0-9.*_-]+))* [!<>=]=? (?:[0-9]+|(?:\$|[nk]r)?[A-ZÆØÅ0-9.*_-]+)(?: (?:[+*\/-<>]|<=|>=|==) (?:[0-9]+|(?:\$|[nk]r)?[A-ZÆØÅ0-9.*_-]+))*/
  end

  def self.get_flag(s)
    get_leading("flag", flag_regexp, s)
  end

  def self.flag_regexp()
    /^^(?:\$|[nk]r)?[A-ZÆØÅ0-9.*_-]+/
  end

  def self.get_leading(name, regexp, s)
    f = s.match(regexp)
    raise "#{s} is not recognizeable as a #{name}" if f.nil?
    #puts "got leading #{name}: #{f.to_s}"
    f.to_s
  end

end
