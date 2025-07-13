#!/usr/bin/env ruby

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

def execute_external(command, args)
  begin
    pid = spawn(command, *args)
    Process.wait(pid)
  rescue Errno::ENOENT
    puts "#{command}: command not found"
  rescue => e
    puts "Error: #{e.message}"
  end
end

loop do
  # Display a prompt
  print "> "
  $stdout.flush

  # Read one line from standard input
  input = gets
  break if input.nil?

  # Separate command and argument by whitespace
  parts = input.chomp.split
  command = parts[0]
  args = parts[1..-1]

  # Skip if no command is entered
  next if command.nil? || command.empty?

  # Run built-in commands
  if execute_builtin(command, args)
    next
  end

  # Run external commands
  execute_external(command, args)
end