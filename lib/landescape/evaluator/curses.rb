require 'curses'
require 'landescape/evaluator'

module Landescape
  module Evaluator
    class Curses < Base
      GRAPHICS_MODES = {
        1 => ::Curses::A_BOLD,
        4 => ::Curses::A_UNDERLINE,
        5 => ::Curses::A_BLINK,
        7 => ::Curses::A_REVERSE
      }

      attr_reader :window

      def initialize(statements, window, options = {})
        super

        @saved_cursor  = nil
        @scroll_region = [0, window.maxy]
      end

      def print(str)
        window.addstr str

        window.refresh
      end

      def set_attributes(*modes)
        return exit_attribute_mode if modes.empty?

        modes.each do |mode|
          next unless attr = GRAPHICS_MODES[mode]

          window.attron attr
        end
      end

      def exit_attribute_mode
        window.attroff GRAPHICS_MODES.values.inject(:|)
      end

      def change_scroll_region(top, bottom)
        @scroll_region = [top, bottom]

        window.setscrreg *@scroll_region
      end

      def scroll_reverse
        window.scrl -1
      end

      def scroll_forward
        window.scrl 1
      end

      def cursor_address(line, column)
        scroll_forward if line > window.cury && window.maxy.pred <= window.cury

        window.setpos line, column
      end

      def newline
        scroll_forward if window.cury == @scroll_region.last

        cursor_address (window.cury.succ), 0
      end

      def carriage_return
        cursor_address window.cury, 0
      end

      def cursor_up(step)
        cursor_address (window.cury - step), window.curx
      end

      def cursor_down(step)
        cursor_address (window.cury + step), window.curx
      end

      def cursor_right(step)
        cursor_address window.cury, (window.curx + step)
      end

      def cursor_left(step)
        cursor_address window.cury, (window.curx - step)
      end

      def save_cursor
        @saved_cursor = [window.cury, window.curx]
      end

      def restore_cursor
        cursor_address *@saved_cursor
      end

      def cursor_visible
        window.curs_set 2
      end

      def cursor_invisible
        window.curs_set 0
      end

      def keypad_xmit
        window.keypad true
      end

      def keypad_local
        window.keypad false
      end

      def clear_screen
        cursor_address 0, 0

        window.clear
        window.refresh
      end

      def clear_eol
        window.clrtoeol

        window.refresh
      end
    end
  end

  Curses = Evaluator::Curses
end
