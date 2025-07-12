#!/usr/bin/env ruby

# Read one line from standard input
input = gets

# Remove new line characters
command = input.chomp

# Execute command
system(command)