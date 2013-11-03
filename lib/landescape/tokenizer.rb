module Landescape
  # Tokenize: "\e[1;2fHi" to ['\e[1;2f', 'H', 'i']]
  class Tokenizer
    class << self
      def start(source)
        new(source).tap(&:start)
      end
    end

    attr_reader :source, :result

    def initialize(source)
      @result = Queue.new
      @source =
        if source.respond_to?(:getc)
          source
        else
          StringIO.new(source.to_s)
        end

      at_exit do
        @source.close unless @source.closed?
      end
    end

    def start
      @tokenize_thread = Thread.fork {
        while char = read_char
          tokens =
            case char
            when nil  then Thread.exit # StringIO#getc # => nil (EOF)
            when /\e/ then escape char
            else char
            end

          Array(tokens).each do |token|
            result.push token
          end
        end
      }
    end

    def stop
      @tokenize_thread.exit if @tokenize_thread.alive?
    end

    private

    def escape(token)
      token << read_char

      case token.chars.to_a.last
      when /\[/
        escape_code token
      when /[()]/
        escape_code_parens token
      when /#/
        escape_code_sharp token
      when /\//
        escape_code_slash token
      when /[\da-zA-Z<=>_\\]/
        token
      else
        fallback token
      end
    end

    def escape_code(token)
      token << read_char

      case token.chars.to_a.last
      when /[\d?;<=>]/
        escape_code token
      when /[a-zA-Z]/
        token
      else
        fallback token
      end
    end

    def escape_code_parens(token)
      token << read_char

      case token.chars.to_a.last
      when /[\da-zA-Z]/
        token
      else
        fallback token
      end
    end

    def escape_code_sharp(token)
      token << read_char

      case token.chars.to_a.last
      when /\d/
        token
      else
        fallback token
      end
    end

    def escape_code_slash(token)
      token << read_char

      case token.chars.to_a.last
      when /[a-zA-Z]/
        token
      else
        fallback token
      end
    end

    def fallback(token)
      token.chars.to_a
    end

    def read_char
      source.getc
    end
  end
end
