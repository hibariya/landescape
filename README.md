# Landescape

Landscape is a library for handling escape sequence.

## Is It Good?

Yes. But Landescape has some problems for now.
**API will changed in future versions.**

Landescape doesn't support followings now:

* Coloring
* Any terminals except vt100

## Installation

Add this line to your application's Gemfile:

    gem 'landescape'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install landescape

## Usage

### Tokenize, And convert to human readable statements

```ruby
source = StringIO.new("\e[1mHello\e[m.") # IO like object

# tokenize
tokenizer = Landescape::Tokenizer.start(source)
tokens    = tokenizer.result # => #<Queue:0x007ff0bc08f098 @que=["\e[1m", "H", "e", "l", "l", "o", "\e[m", "."], (snip...)>

# convert
converter = Landescape::Converter::VT100.start(tokens, non_block: true)
converter.result # => #<Queue:0x007ff0bc1cdc70 @que=[[:set_attributes, 1], [:print, "H"], [:print, "e"], [:print, "l"], [:print, "l"], [:print, "o"], [:exit_attribute_mode], [:print, "."]], (snip...)>
```

### Invoke shell on Curses window

```ruby
require 'curses'
require 'pty'
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
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
