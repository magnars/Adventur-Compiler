class ChangeTracker
  def initialize(source_directory, target_directory)
    @source_directory, @target_directory = source_directory, target_directory
    @state_file = "#{@target_directory}/last_compile.txt"
  end
  
  def changed_rooms
    puts "finding all changed rooms... "
    start = Time.now
    changed_rooms = find_changed_rooms
    puts "done after #{Time.now - start} seconds."
    changed_rooms
  end
  
  def save_current_state!
    `touch #{@state_file}`
  end

  private
  
  def find_changed_rooms
    if File.exists? @state_file
      `find #{@source_directory} -newer #{@state_file} | grep -v .svn | grep -v gitte-krav.txt | grep -v notat.txt | grep .txt`
    else
      `find #{@source_directory} | grep -v .svn | grep -v last_compile.txt | grep .txt`
    end.map { |line| $1.to_i if line =~ /A(\d+)\.txt$/ }
  end
  
end
