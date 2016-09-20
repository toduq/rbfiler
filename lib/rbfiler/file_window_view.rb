module Rbfiler
  class FileWindowView
    def draw(model, refresh=false)
      # get information
      @active, @pane, @message = model.to_a

      # vars
      arr = []
      x, y, width, height = Draw.config

      # create array for Draw.draw()
      horizontal_separator = '+' + '-'*width + '+' + '-'*width + '+'
      arr.push horizontal_separator
      arr.push '|' + (@pane[0][:dir]).mb_ljust(width) + '|' + (@pane[1][:dir]).mb_ljust(width) + '|'
      arr.push horizontal_separator
      height.times do |i|
        left, right = [0, 1].map do |pane|
          if i == 0 && @pane[pane][:files].empty?
            # directory is empty
            text = @pane[pane][:has_hidden] ? 'directory only has hidden files' : 'directory is empty'
            Draw::ESC_TEXT_RED + text.ljust(width) + Draw::ESC_RESET
          else
            position = i + @pane[pane][:scroll]
            if @pane[pane][:files][position].nil?
              # empty
              ' ' * width
            else
              # file exists
              is_cursor_on_file = position == @pane[pane][:cursor] && pane == @active
              is_marked = @pane[pane][:mark].include? position
              decorate(@pane[pane][:files][position], width, is_cursor_on_file, is_marked)
            end
          end
        end
        arr.push '|' + left + '|' + right + '|'
      end
      arr.push horizontal_separator
      arr.push @message

      # refresh screen
      Draw.draw(arr, refresh)
    end

    private

    def decorate(file, width, is_active=false, is_marked=false)
      suffix = ''
      if file[:stat].file?
        suffix = ' ' + file[:stat].size.to_filesize
        width -= suffix.length
      end
      basename = file[:name]
      basename += " -> #{File.readlink(file[:fullpath])}" if file[:lstat].symlink?
      basename = basename.mb_ljust(width) + suffix
      prefix = ''
      prefix += Draw::ESC_DIR if file[:stat].directory?
      prefix += Draw::ESC_MARKED if is_marked
      prefix += Draw::ESC_CURSOR if is_active
      prefix + basename + Draw::ESC_RESET
    end
  end
end


# override
class String
  def mb_ljust(width, padding=' ')
    output_width = each_char.map { |c| c.bytesize == 1 ? 1 : 2 }.reduce(0, &:+)
    padding_size = [0, width - output_width].max
    (self + padding * padding_size)[0, width]
  end
end

class Integer
  def to_filesize
    {
        'B ' => 1024,
        'KB' => 1024 * 1024,
        'MB' => 1024 * 1024 * 1024,
        'GB' => 1024 * 1024 * 1024 * 1024,
        'TB' => 1024 * 1024 * 1024 * 1024 * 1024
    }.each_pair { |e, s| return sprintf('%.1f', self.to_f / (s / 1024)) + e if self < s }
  end
end