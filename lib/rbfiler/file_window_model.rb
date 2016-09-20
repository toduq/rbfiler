module Rbfiler
  class FileWindowModel
    attr_reader :pane, :active_pane_no, :ap, :op
    attr_accessor :message

    def initialize
      @pane = [0, 1].map do
        {
            dir: Dir.pwd,
            files: [],
            has_hidden: false,
            mark: [],
            cursor: 0,
            scroll: 0,
            option: []
        }
      end
      set_default_message
      change_active_pane(0)
      load_file
    end

    def set_default_message
      x, y, width, height = Draw.config
      @message = '[hjkl], [~]home, [g]o, [c]opy, [m]ove, [r]name, [d]elete, [C-d]force delete, [n]ew dir, [:]exec, [q]uit'[0, width*2+3]
    end

    def change_active_pane(pane=nil)
      pane = (@active_pane_no+1)%2 if pane.nil?
      @active_pane_no = pane
      @ap = @pane[@active_pane_no]
      @op = @pane[(@active_pane_no+1)%2]
    end

    def load_file(*target)
      target = [0, 1] if target.empty?
      target.each do |pane|
        # load filename and File::Stat
        glob_pattern = @pane[pane][:option].include?(:hidden) ? '/{,.}*' : '/*'
        files = Dir.glob(@pane[pane][:dir] + glob_pattern).map { |name|
          next if %w(. ..).include? File.basename(name)
          {name: File.basename(name), fullpath: name, stat: File.stat(name), lstat: File.lstat(name)}
        }.compact
        files = files.sort_by { |f| f[:name] }
        files = files.group_by { |f| f[:stat].directory? }
        files = [*files[true], *files[false]]

        # if file list has changed, remove marks.
        if @pane[pane][:files].length != files.length
          @pane[pane][:mark] = []
        end
        # check file exists under the cursor
        if files[@pane[pane][:cursor]].nil?
          @pane[pane][:cursor] = [0, files.length-1].max
        end

        @pane[pane][:files] = files
        @pane[pane][:has_hidden] = Dir.glob(@pane[pane][:dir] + '/.*').length != 2
      end
    end

    def to_a
      [@active_pane_no, @pane, @message]
    end

    def expand_path(command)
      # when [/home, /dev] is selected
      # 'ls @list' will be expanded to ['ls /home /dev']
      # 'ls @each' will be expanded to ['ls /home', 'ls /dev']
      # also you can use @list and @each multiple times
      # 'ls @list @each' will be expanded to ['ls /home /dev /home', 'ls /home /dev /dev']

      selected_files = get_target_files
      list = []
      command.gsub!('@list', selected_files.join(' '))
      command.gsub!('@ap', @ap[:dir])
      command.gsub!('@op', @op[:dir])
      if command.include?('@each')
        # execute command multiple times on each file
        selected_files.each do |fullpath|
          list.push command.gsub('@each', fullpath)
        end
      else
        # just execute
        list.push command
      end
      list
    end

    def get_target_files
      return [] if @ap[:files].empty?
      if @ap[:mark].empty?
        target = [@ap[:files][@ap[:cursor]][:fullpath]]
      else
        target = @ap[:mark].map { |i| @ap[:files][i][:fullpath] }
      end
      target.map{|path| Shellwords.escape(path)}
    end

    private
    def _switch_option(sym)
      if @ap[:option].include? sym
        @ap[:option].delete sym
      else
        @ap[:option].push sym
      end
    end

    def _change_directory(path)
      @ap[:dir] = path
      @ap[:cursor] = 0
      @ap[:scroll] = 0
      @ap[:mark] = []
      load_file(@active_pane_no)
    end
  end
end