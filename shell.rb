#!/usr/bin/env ruby

loop do
  # Display a prompt
  print "> "

  # Flush and immediately display standard output
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

  # Start process
  pid = spawn(command, *args)

  # Wait for the process to finish
  Process.wait(pid)
end