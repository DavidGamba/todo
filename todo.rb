#!/usr/bin/ruby
# add current dir to the path
$: << File.join(File.dirname(__FILE__))

class Todo
  require 'date'
  require 'fileutils'

  def initialize
    @dir = "#{ENV['HOME']}/.todo"
    FileUtils.mkdir @dir unless Dir.exists? @dir
  end

  def list
    i = 0
    Dir.entries(@dir).sort.each do |f|
      next if File.directory? f
      i+=1
#     puts "#{i}: #{f}"
      file = File.open("#{@dir}/#{f}", 'r')
      puts "#{i}: #{file.readline}"
      file.close
    end
  end

  def get_file_by_index(index)
    i = 0
    Dir.entries(@dir).sort.each do |f|
      next if File.directory? f
      i+=1
      if i == index.to_i
        return f
      end
    end
    return nil
  end

  def delete(index)
    f = get_file_by_index(index)
    abort "Wrong index" if f.nil?
    puts "rm #{f}"
    File.delete "#{@dir}/#{f}"
  end

  def create(subject, priority)
    file = "#{@dir}/#{now}-#{priority}-open.adoc"
    puts file
    puts subject
    f = File.open(file, 'w')
    f.write template(subject)
    f.close
  end

  def edit(index)
    f = get_file_by_index(index)
    abort "Wrong index" if f.nil?
    puts "edit #{f}"
    system("vim #{@dir}/#{f}")
  end

  def template(subject)
    file = <<EOF
#{subject}
EOF
  end

  def now
    DateTime.now.strftime('%Y%m%d_%H%M%S')
  end
end

# Only run the following code when this file is the main file being run
# instead of having been required or loaded by another file
if __FILE__==$0
  action = ARGV.shift
  todo = Todo.new
  case action
  when /create/i
    subject  = ARGV.shift
    abort "Missing subject" unless subject
    priority = ARGV.shift || 'normal'
    todo.create(subject, priority)
  when /list/i
    todo.list
  when /edit/i
    index = ARGV.shift
    abort "Missing index" unless index
    todo.edit(index)
  when /rm/i
    index = ARGV.shift
    abort "Missing index" unless index
    todo.delete(index)
  end
end
