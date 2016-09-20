module Rbfiler
  # this file extends FileWindowModel
  class FileWindowModel
    def scroll_up
      @ap[:cursor] = [@ap[:cursor]-1, 0].max
      @ap[:scroll] = [@ap[:scroll], @ap[:cursor]].min
    end

    def scroll_down
      x, y, width, height = Draw.config
      @ap[:cursor] = [@ap[:cursor]+1, @ap[:files].length-1].min
      @ap[:scroll] = [@ap[:scroll], @ap[:cursor]-height+1].max
    end

    def goto_letter(ch)
      ch = ch.downcase
      search_list = [*@ap[:files][@ap[:cursor]+1, @ap[:files].length], *@ap[:files]]
      target = search_list.find { |f|
        if f[:name][0] == '.' && f[:name].length > 1
          ch == f[:name][1].downcase
        else
          ch == f[:name][0].downcase
        end
      }
      return if target.nil?
      diff = @ap[:files].index(target) - @ap[:cursor]
      diff.abs.times do
        diff > 0 ? scroll_down : scroll_up
      end
    end

    def mark
      index = @ap[:cursor]
      if @ap[:mark].include? index
        @ap[:mark].delete index
      else
        @ap[:mark].push index
      end
      scroll_down
    end

    def cursor_left
      @active_pane_no == 1 ? change_active_pane(0) : dir_move_up
    end

    def cursor_right
      @active_pane_no == 0 ? change_active_pane(1) : dir_move_up
    end

    def dir_move_up
      set_default_message
      _change_directory Pathname(@ap[:dir]).parent.to_s
    end

    def dir_move_down
      set_default_message
      dest_dir_name = @ap[:files][@ap[:cursor]][:name]
      _change_directory (Pathname(@ap[:dir]) + dest_dir_name).to_s
    end

    def dir_go(path, opposite=false)
      change_active_pane if opposite
      if File.exists?(File.expand_path(path, @ap[:dir]))
        _change_directory File.expand_path(path, @ap[:dir])
      else
        @message = Draw::ESC_TEXT_RED + 'Directory not found' + Draw::ESC_RESET
      end
      change_active_pane if opposite
    end

    def mkdir(name)
      Dir.mkdir(Pathname(@ap[:dir]) + name)
      load_file
    end

    def file_move
      get_target_files.each do |path|
        FileUtils.move path, @op[:dir] + '/'
      end
      load_file
    end

    def file_copy
      get_target_files.each do |path|
        if File.directory?(path)
          FileUtils.cp_r path, @op[:dir]
        else
          FileUtils.copy path, @op[:dir]
        end
      end
      load_file
    end

    def file_rename(name)
      old_name = @ap[:files][@ap[:cursor]][:fullpath]
      new_name = (Pathname(@ap[:dir]) + name).to_s
      File.rename(old_name, new_name)
      load_file
    end

    def file_edit
      dest_file_name = @ap[:files][@ap[:cursor]][:fullpath]
      system('vim', dest_file_name)
      load_file
    end

    def option_hidden
      _switch_option(:hidden)
      load_file(@active_pane_no)
    end

    private
    def __dummy
      # for RubyMine inspection
      @ap = @op = @active_pane_no = nil
    end
  end
end
