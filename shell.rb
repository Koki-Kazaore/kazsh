#!/usr/bin/env ruby

loop do
  # Display a prompt
  print "> "

  # Flush and immediately display standard output
  $stdout.flush

  # Read one line from standard input
  input = gets

  # Ctrl+D (EOF) to exit
  break if input.nil?

  # Execute command
  command = input.chomp
  system(command)
end