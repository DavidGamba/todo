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

  def initialize(options = {})
    @dir = "#{ENV['HOME']}/.todo"
    @todo_ext  = options[:todo_ext]
    @track_ext = options[:track_ext]
    FileUtils.mkdir @dir unless Dir.exists? @dir
  end

  # lists all files in @dir and prints them in 'sort' order. If filter
  # equals yml then the filename is printed, otherwise the first line is
  # printed (the subject line).
  # * *Args* :
  #   - +filter+ -> optional, the filename must match the filter
  # * *Returns* :
  #   - List of filtered files in sorted order
  def list filter = @todo_ext, filename = false
    i = 0
    Dir.entries(@dir).sort.reverse.each do |f|
      next if File.directory? f
      next unless f.match(/#{filter}$/i)
      i+=1
      if filter == @track_ext || filename
        puts "#{i}: #{f}"
      else
        file = File.open("#{@dir}/#{f}", 'r')
        puts "#{i}: #{file.readline}"
        file.close
      end
    end
  end

  def delete index, filter = @todo_ext
    f = get_file_by_index(index, filter)
    abort "Wrong index" if f.nil?
    puts "rm #{f}"
    File.delete "#{@dir}/#{f}"
  end

  def create_task subject, priority, edit = false
    file = "#{@dir}/#{now}-#{priority}-open.adoc"
    puts file
    puts subject
    f = File.open(file, 'w')
    f.write template(subject)
    f.close
  end

  def edit index, filter = @todo_ext
    f = get_file_by_index(index, filter)
    abort "Wrong index" if f.nil?
    puts "edit #{f}"
    system("vim #{@dir}/#{f}")
  end

  def close index, filter = @todo_ext
    f = get_file_by_index(index, filter)
    abort "Wrong index" if f.nil?
    puts "close #{f}"
    closed_f = f.gsub(/-open\.adoc$/,'-closed.adoc')
    FileUtils.mv("#{@dir}/#{f}", "#{@dir}/#{closed_f}")
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
  def track(index = 1)
    file = get_file_by_index(index, @track_ext)
    abort "Wrong index" if file.nil?
    puts file
    f = YAML.load_file "#{@dir}/#{file}"
    f.each do |time,info|
      tod = Time.parse(time).strftime('%H:%M:%S')
      subject = info['subject']
      lenght  = info['lenght']
      lenght  = (lenght / 3600 ).round(2) if lenght
      printf("%-s (%5s) %s\n",tod, lenght, subject)
    end
  end

  private

    def get_file_by_index(index, filter = '')
      i = 0
      Dir.entries(@dir).sort.reverse.each do |f|
        next if File.directory? f
        next unless f.match(/#{filter}$/i)
        i+=1
        if i == index.to_i
          return f
        end
      end
      return nil
    end

    def template(subject)
      file = <<EOF
#{subject}
EOF
    end

end

# Only run the following code when this file is the main file being run
# instead of having been required or loaded by another file
if __FILE__==$0
  require 'optparse'
  require 'binman'

  options = {}
  options[:todo_ext]         = 'adoc'
  options[:closed_todo_ext]  = '-closed.adoc'
  options[:track_ext]        = 'yml'

  options[:extension]     = options[:todo_ext]
  optparse = OptionParser.new do |opts|
    opts.on("-p <priority>", "priority") do |opt|
      options[:priority] = opt
    end
    opts.on("-t", "--track", "day track") do |opt|
      options[:extension] = options[:track_ext]
    end
    opts.on("-f", "--filename", "print filename") do |opt|
      options[:filename] = opt
    end
    opts.on("-c", "--closed", "list closed todos") do |opt|
      options[:list_closed] = opt
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
  todo = Todo.new(options)
  case action
  when /list/i
    if options[:list_closed]
      todo.list options[:closed_todo_ext], options[:filename]
    else
      todo.list options[:extension], options[:filename]
    end
  when /create/i
    subject = ARGV.join(' ')
    abort "Missing subject" unless subject
    priority = options[:priority] || 'normal'
    edit     = options[:edit]
    todo.create_task subject, priority, edit
  when /time/i
    subject = ARGV.join(' ')
    abort "Missing subject" unless subject
    todo.time subject
  when /track/i
    index = ARGV.shift || 1
    todo.track index
  when /edit/i
    index = ARGV.shift || 1
    todo.edit index, options[:extension]
  when /close/i
    index = ARGV.shift
    abort "Missing index" unless index
    todo.close index, options[:extension]
  when /rm/i
    index = ARGV.shift
    abort "Missing index" unless index
    todo.delete index, options[:extension]
  else
    todo.list options[:extension], options[:filename]
  end
end
