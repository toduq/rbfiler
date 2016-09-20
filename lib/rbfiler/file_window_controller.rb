module Rbfiler
  class FileWindowController
    def initialize
      @view = FileWindowView.new
      @model = FileWindowModel.new
    end

    def main
      @view.draw(@model)
      print Draw::ESC_CURSOR_HIDDEN

      while (c = STDIN.getch)
        @message = c
        @refresh = false
        case c
          # cursor moving
          when ?k, ?\C-p
            @model.scroll_up
          when ?j, ?\C-n
            @model.scroll_down
          when ?A..?Z
            @model.goto_letter(c)
          when ' '
            @model.mark

          # directory moving
          when ?l, ?\C-f
            @model.cursor_right
          when ?h, ?\n
            @model.cursor_left
          when ?\r # enter
            next if @model.ap[:files].empty?
            if @model.ap[:files][@model.ap[:cursor]][:stat].directory?
              @model.dir_move_down
            else
              @model.file_edit
            end
          when ?~
            @model.dir_go '~' # go home
          when ?o
            @model.dir_go @model.op[:dir] # current pane go same directory as opposite
          when ?\C-o
            @model.dir_go @model.ap[:dir], true # opposite pane go same directory as current
          when ?g # input path from STDIN
            @model.dir_go get_line('change directory')

          # file control
          when ?c
            @model.file_copy
          when ?m
            @model.file_move
          when ?r
            @model.file_rename get_line('rename ' + @model.ap[:files][@model.ap[:cursor]][:name] + ' to ')
          when ?d
            message = 'Are you sure to delete ' + @model.expand_path('@list')[0] + ' [yn]'
            if get_line(Draw::ESC_TEXT_RED + message + Draw::ESC_RESET) == 'y'
              execute_command 'rm @each'
            end
          when ?\C-d
            message = 'Are you sure to !FORCE! delete ' + @model.expand_path('@list')[0] + ' [yn]'
            if get_line(Draw::ESC_TEXT_RED + message + Draw::ESC_RESET) == 'y'
              execute_command 'rm -rf @each'
            end

          # directory control
          when ?n
            @model.mkdir get_line('make directory')

          # options
          when ?.
            @model.option_hidden

          # others
          when ?: # execute command
            execute_command get_line('execute command'), true

          # else
          when ?\C-c, ?q
            break
          else
            next
        end
        @view.draw(@model, @refresh)
      end

      print Draw::ESC_CURSOR_SHOW
    end

    def execute_command(command, wait=false)
      @model.expand_path(command).each do |cmd|
        system(cmd, chdir: @model.ap[:dir])
      end
      get_ch('push some key to continue') if wait || !$?.success?
      @model.load_file
    end

    def execute_command_in_background(command)
      @model.message = ''
      @model.expand_path(command).each do |cmd|
        o, e, s = Open3.capture3(cmd)
        @model.message += o.gsub('\n', ' ') unless o.nil?
        @model.message += Draw::ESC_TEXT_RED + e.gsub('\n', ' ') + Draw::ESC_RESET unless e.nil?
      end
    end

    def get_ch(prefix)
      Draw.clear_line
      print prefix + ' : '
      STDIN.getch
    end

    def get_line(prefix)
      @refresh = true
      Draw.clear_line
      print prefix + ' : '
      STDIN.gets.strip
    end

  end
end