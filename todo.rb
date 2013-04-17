#!/usr/bin/env ruby
# add current dir to the path
$: << File.join(File.dirname(__FILE__))

class Todo
  require 'date'
  require 'fileutils'
  require 'yaml'
  require 'time'

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

  def time(subject)
    day = DateTime.now.strftime('%Y%m%d')
    second = now
    file = "#{@dir}/#{day}-track.yml"
    if File.exists? file
      yml = YAML.load_file file
      last_entry = nil
      yml.each do |time,info|
        last_entry = time unless last_entry
        if Time.parse(time) > Time.parse(last_entry)
          last_entry = time
        end
      end
      lenght = Time.parse(second) - Time.parse(last_entry)
      yml[last_entry]['lenght'] = lenght
      yml[second] = Hash.new
      yml[second]['subject'] = subject
      yml[second]['lenght'] = nil
      f = File.open(file, 'w')
      f.write yml.to_yaml
      f.close
    else
      puts subject
      yml = Hash.new
      yml[second] = Hash.new
      yml[second]['subject'] = subject
      yml[second]['lenght'] = nil
      f = File.open(file, 'a')
      f.write yml.to_yaml
      f.close
    end
  end

  def track(days_ago = 0)
    day = DateTime.now.strftime('%Y%m%d')
    file = "#{@dir}/#{day}-track.yml"
    return unless File.exists? file
    f = YAML.load_file file
    f.each do |time,info|
      tod = Time.parse(time).strftime('%H:%M:%S')
      subject = info['subject']
      lenght  = info['lenght']
      lenght  = (lenght / 60 ).round(2) if lenght
      printf("%-s (%5s) %s\n",tod, lenght, subject)
    end
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
  when /time/i
    subject  = ARGV.shift
    abort "Missing subject" unless subject
    todo.time(subject)
  when /track/i
    todo.track
  end
end
