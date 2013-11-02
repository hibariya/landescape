require 'thread'
require 'landescape/version'

module Landescape
  autoload :Tokenizer, 'landescape/tokenizer'
  autoload :Converter, 'landescape/converter'
  autoload :Evaluator, 'landescape/evaluator'

  autoload :Curses,    'landescape/evaluator/curses'

  class Nullogger
    def method_missing(*); end
  end

  class << self
    attr_writer :logger

    def logger
      @logger ||= Nullogger.new
    end

    def run(source, window, options = {})
      options = {non_block: false, converter: Converter::VT100, evaluator: Curses}.merge(options)
      converter_klass, evaluator_klass = [:converter, :evaluator].map {|n|
        options.delete(n)
      }

      tokenizer = Tokenizer.start(source)
      converter = converter_klass.start(tokenizer.result, options)

      evaluator_klass.start(converter.result, window, options).tap {|evaluator|
        at_exit do
          [tokenizer, converter, evaluator].each &:stop
        end
      }
    end
  end
end
