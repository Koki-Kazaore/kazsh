#!/usr/bin/env ruby
require 'open3'

def execute_builtin(command, args)
  case command
  when "cd"
    # If no argument, go to home directory
    dir = args.empty? ? ENV['HOME'] : args[0]
    begin
      Dir.chdir(dir)
      true
    rescue => e
      puts "cd: #{e.message}"
      true
    end
  when "exit"
    exit
  else
    false
  end
end

def execute_pipeline(commands)
  return if commands.empty?

  # For a single command
  if commands.length == 1
    parts = commands[0].strip.split
    command = parts[0]
    args = parts[1..-1]

    if execute_builtin(command, args)
      return
    end

    begin
      pid = spawn(command, *args)
      Process.wait(pid)
    rescue Errno::ENOENT
      puts "#{command}: command not found"
    rescue => e
      puts "Error: #{e.message}"
    end
    return
  end

  # For a pipeline of commands
  # Pre-create pipes
  pipes = []
  (commands.length - 1).times do
    pipes << IO.pipe
  end

  ios = []
  pids = []

  commands.each_with_index do |cmd, index|
    parts = cmd.strip.split
    command = parts[0]
    args = parts[1..-1]

    # I/O settings
    options = {}

    # Create a pipe
    if index < commands.length - 1
      read_pipe, write_pipe = IO.pipe
      ios << [read_pipe, write_pipe]
    end

    # Standard input settings
    stdin = index == 0 ? :in : ios[index - 1][0]

    # Standard output settings
    stdout = index == commands.length - 1 ? :out : ios[index][1]

    # Start process
    begin
      pid = spawn(command, *args, in: stdin, out: stdout)
      pids << pid
    rescue Errno::ENOENT
      puts "#{command}: command not found"
      # Clean up pipes
      ios.each { |r, w| [r, w].each(&:close) rescue nil }
      pids.each { |p| Process.kill('TERM', p) rescue nil }
      return
    end

    # Close used pipes
    if index > 0
      ios[index - 1][0].close
    end
    if index < commands.length - 1
      ios[index][1].close
    end
  end

  # Wait for the last command to finish
  pids.each { |pid| Process.wait(pid) }

  # Close the remaining pipes
  ios.each { |r, w| [r, w].each(&:close) rescue nil }
end

loop do
  # Display a prompt
  print "> "
  $stdout.flush

  # Read one line from standard input
  input = gets
  break if input.nil?

  # Split by pipe
  commands = input.chomp.split("|")

  # Skip if no command is entered
  next if commands.empty?

  execute_pipeline(commands)
end