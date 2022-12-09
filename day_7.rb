class Directory
  attr_accessor :name, :files, :sub_dirs, :size, :parent_dir

  def initialize(name = '/', parent_dir = nil)
    @name = name
    @parent_dir = parent_dir
    @files = {}
    @sub_dirs = {}
    @size = 0
  end

  def add_file(file_name, file_size)
    @files[file_name] = file_size
    update_size(file_size.to_i)
  end

  def update_size(file_size)
    @size += file_size
    unless parent_dir.nil?
      parent_dir.update_size(file_size)
    end
  end

  def collect_dirs(dirs = [], &test)
    dirs << self if test.call(self)
    @sub_dirs.each {| k, v|
      puts("collect #{k}")
      v.collect_dirs(dirs, &test)
    }
    dirs
  end
end

class String
  def is_command?
    self =~ /^\$.*/
  end
end

base_dir = Directory.new
current_dir = base_dir

File.open("day_7.input").each_line do |line|
  puts(line)
  if line.is_command?
    _, command, arg = line.split
    case command
    when "ls"
      puts "LIST"
    when "cd"
      if arg == ".."
        current_dir = current_dir.parent_dir unless current_dir.parent_dir.nil?
        puts "go back to #{current_dir.name}"
      elsif arg == "/"
        current_dir = base_dir
      else
        new_dir = current_dir.sub_dirs[arg] || Directory.new(arg, current_dir)
        puts "go from #{current_dir.name} to #{new_dir.name}"
        current_dir = new_dir
      end
    end
  else
    cat, name = line.split
    case cat
    when "dir"
      puts "add subdir #{name}"
      current_dir.sub_dirs[name] = Directory.new(name, current_dir)
    else
      puts "add file #{name}"
      puts "old size #{current_dir.size}"
      current_dir.add_file(name, cat)
      puts "new size #{current_dir.size}"
    end
  end
end

avail_space = 70_000_000 - base_dir.size
size_needed = 30_000_000
delta = size_needed - avail_space
lil_buddies = base_dir.collect_dirs([]) {|dir| dir.size > delta}
lil_buddies.sort! {|d1, d2| d1.size <=> d2.size }
puts lil_buddies.last