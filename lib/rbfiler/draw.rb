module Rbfiler
  class Draw
    ESC_DIR = "\e[33m"
    ESC_CURSOR = "\e[44m"
    ESC_MARKED = "\e[45m"
    ESC_TEXT_RED = "\e[31m"
    ESC_RESET = "\e[0m"

    ESC_CURSOR_HIDDEN = "\e[>5l"
    ESC_CURSOR_SHOW = "\e[>5h"

    class << self
      def draw(arr, refresh=false)
        @old_arr ||= []
        move_to(0, 1)
        arr.each_with_index do |line, i|
          next if @old_arr[i] == line && !refresh
          move_to(0, i+1)
          clear_line
          print line
        end
        @old_arr = arr
        move_to(0, config[1])
      end

      def config
        y, x = STDIN.winsize
        pane_width = (x-3) / 2
        pane_height = y - 5
        [x, y, pane_width, pane_height]
      end

      def move_to(x, y)
        print "\033[#{y};#{x}H"
      end

      def clear_line
        print "\033[K"
      end
    end
  end
end