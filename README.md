# Rbfiler

![img](https://raw.githubusercontent.com/yuusuke12dec/images/master/screenshot.png)

Tiny, dual-pane, easy-install File Manager for CUI.


## Installation

    $ gem install rbfiler    
    $ rbfiler

## How to use

### basic

You can override every key setting by config file.

- `j` : cursor down
- `k` : cursor up
- `h` : move to parent directory(on left pane) or change pane(on right pane)
- `l` : move to parent directory(on right pane) or change pane(on left pane)
- `Enter` : enter directory or edit file
- `q` or `C-c` : quit

### move

- `Capital Alphabet(A-Z)`  
move cursor to the file which starts with the alphabet
- `~` : move to home directory
- `o` : set current pane's directory as same as opposite one
- `C-o` : set opposite pane's directory as same as current one
- `g` : input directory name and go there
- `.` : toggle display of hidden files

### control

- `Space` : mark file for copy, move, or delete
- `c` : copy files or directories
- `m` : move files or directories
- `d` : delete files
- `C-d` : force delete directories (rm -rf)
- `n` : create empty directory
- `:` : execute command on the current directory

You can copy, move, or delete multiple files at once by mark them by `Space` key.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yuusuke12dec/rbfiler. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

