#!/usr/bin/env ruby
=begin

# TODO 1 2013-05-29 0.1

## NAME

todo - keep track of your day!

## SYNOPSIS

`todo` [--help] [--version] [*COMMAND*] [*OPTIONS*]

## COMMANDS

`list` [-t|--track] [-f|--filename] [-c|--closed]
  Show a list of todo's (default) or a list of day tracks.

  Note: The index given by this command can be used everywhere else.

  `--track` Show index for tracks.

  `--filename` Show filename for todo's instead of subject.

  `--closed` Show closed todo's.

`create` *SUBJECT* [-e|--edit] [-p|--priority *PRIORITY*]
  Create a todo. Use --edit to launch an editor after creation.

`time` *SUBJECT*
  Track a new activity in your day track.

`track` [*INDEX*]
  Show the given day's (defaults to current) tracked activities.

`edit` *INDEX* [-t|--track] [-c|--closed]
  Edit a todo (default) or a day track.

  `--track` Edit tracks.

  `--closed` Edit closed todo's.

`close` *INDEX*
  Close a todo.

`reopen` *INDEX*
  Reopen a todo.

`rm` *INDEX* [-t|--track] [-c|--closed]
  Delete a todo (default) or a day track.

  `--track` Delete tracks.

  `--closed` Delete closed todo's.

## BUG REPORTS

https://github.com/DavidGamba/todo.git

=end

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

  # Add an activity to the track file
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

  # Shows timed activities
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
  require 'optparse'
  require 'binman'


  options = {}
  actions = {}
  optparse = OptionParser.new do |opts|
    opts.on("-p <priority>", "priority") do |opt|
      options[:priority] = opt
    end
    opts.on("-h", "--help") do
      BinMan.show
      exit
    end
    opts.on("--version") do
      puts "#{File.basename($0)} 0.1"
      exit
    end
  end
  optparse.parse!

  action = ARGV.shift
  todo = Todo.new
  case action
  when /create/i
    subject  = ARGV.shift
    abort "Missing subject" unless subject
    priority = options[:priority] || 'normal'
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
  else
    todo.list
  end
end
