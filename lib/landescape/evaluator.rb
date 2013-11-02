module Landescape
  module Evaluator
    class Base
      class << self
        def start(statements, window, options = {})
          new(statements, window, options).tap(&:start)
        end
      end

      attr_reader :statements

      def initialize(statements, window, options = {})
        @options    = {non_block: false}.merge(options)
        @window     = window
        @statements = statements
      end

      def start
        @eval_thread = Thread.fork {
          loop do
            name, *args =
              begin
                statements.shift(@options[:non_block])
              rescue ThreadError
                Thread.kill
              end

            if self.class.method_defined?(name)
              __send__ name, *args
            else
              not_supported name, *args
            end
          end
        }
      end

      def stop
        @eval_thread.exit if @eval_thread.alive?
      end

      def unknown(token)
        Landescape.logger.warn %([unknown] #{token.inspect})
      end

      def not_supported(name, *args)
        Landescape.logger.warn %([not supported] #{name}(#{args.join(', ')}))
      end
    end
  end
end
