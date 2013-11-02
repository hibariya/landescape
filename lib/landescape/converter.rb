module Landescape
  # Convert: ['\e[1;2f', 'H', 'i']] to [[:cursor_address, 1, 2], [:print, 'H'], [:print, 'i']]
  module Converter
    class Base
      CODES = {}

      class << self
        def start(tokens, options = {})
          new(tokens, options).tap(&:start)
        end
      end

      attr_reader :tokens, :result

      def initialize(tokens, options = {})
        @options = {non_block: false}.merge(options)
        @result  = Queue.new
        @tokens  = tokens
      end

      def start
        @convert_thread = Thread.fork {
          loop do
            token =
              begin
                tokens.shift(@options[:non_block])
              rescue ThreadError
                Thread.exit
              end

            _, detected = self.class::CODES.detect {|pattern, _| pattern === token }
            match       = Regexp.last_match
            statement   =
              if detected
                name, args_proc = detected.values_at(:name, :args)
                args            = args_proc ? args_proc.call(match.captures) : nil

                Landescape.logger.debug %([statement] #{name}(#{Array(args).join(', ')}))
                [name, *args]
              else
                Landescape.logger.debug %([statement] print(#{token.inspect}))
                [:print, *token]
              end

            result.push statement
          end
        }
      end

      def stop
        @convert_thread.exit if @convert_thread.alive?
      end
    end

    class VT100 < Base
      CODES = {
        /^\e\[(\d+)?(?:;(\d+))?[Hf]$/ => {
          name: :cursor_address,
          args: ->(captures) { captures.map(&:to_i) }
        },

        /^\e\[(\d+)?A$/ => {
          name: :cursor_up,
          args: ->(captures) { captures.first.to_i }
        },

        /^\e\[(\d+)?B$/ => {
          name: :cursor_down,
          args: ->(captures) { captures.first.to_i }
        },

        /^\e\[(\d+)?C$/ => {
          name: :cursor_right,
          args: ->(captures) { captures.first.to_i }
        },

        /^\e\[(\d+)?D$/ => {
          name: :cursor_left,
          args: ->(captures) { captures.first.to_i }
        },

        /^\e\[0?m$/ => {name: :exit_attribute_mode},

        /^\e\[([\d;]+)m$/ => {
          name: :set_attributes,
          args: ->(captures) { captures.join.split(/;/).map(&:to_i) }
        },

        /^\e\[(\d+);(\d+)r$/ => {
          name: :change_scroll_region,
          args: ->(captures) { captures.map(&:to_i) }
        },

        /^\e\[s$/   => {name: :save_cursor},
        /^\e\[u$/   => {name: :restore_cursor},
        /^\e\[2?J$/ => {name: :clear_screen},
        /^\e\[K$/   => {name: :clear_eol},

        /^\eD$/ => {name: :scroll_forward},
        /^\eM$/ => {name: :scroll_reverse},

        /^\e\[\?1h$/ => {name: :keypad_xmit},
        /^\e\[\?1l$/ => {name: :keypad_local},

        # cursor_normal is probably not available on vt100
        /^\e\[\?25h$/ => {name: :cursor_visible},
        /^\e\[\?25l$/ => {name: :cursor_invisible},

        # backslashes
        /^\n$/   => {name: :newline},
        /^\r$/   => {name: :carriage_return},
        /^(\a)$/ => {name: :bell},

        # really...? maybe doubt!
        /^\e\\$/ => {name: :carriage_return},

        /^(\u000F|\e.+)$/ => {
          name: :unknown,
          args: ->(captures) { captures.first }
        }
      }
    end
  end
end
