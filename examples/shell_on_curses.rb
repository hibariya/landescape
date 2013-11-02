#!/usr/bin/env ruby

require 'pty'
require 'curses'
require 'landescape'

Curses.noecho

window = Curses.stdscr
window.addstr 'Landescape example for curses'
window.refresh

terminal = window.subwin(27, 102, 10, 10)
terminal.scrollok true

PTY.getpty 'TERM=vt100 bash --noprofile' do |stdout, stdin, pid|
  stdin.puts <<-SHELL
    tput cols 100
    tput lines 25
    clear
  SHELL

  Thread.fork do
    while char = terminal.getch
      stdin.putc char
    end
  end

  Landescape.run stdout, terminal

  Curses.close_screen if Process.detach(pid).join
end
