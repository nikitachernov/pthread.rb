require 'drb/drb'

module Pthread

  # +PthreadExecutor+ is used by Pthread to run code in a separate fork.
  # Users can you this class to start executors manually on remote machines.
  class PthreadExecutor

    # Initliazes new executor.
    #
    # @param [ String ] DRB host that has main programm running
    # @param [ String, Symbol ] optinal queue name to attach executor
    #
    # @example Connect to remote Drb service
    #   Pthread::PthreadExecutor.new '192.168.1.100:12345', :tasks
    def initialize(host, queue=nil)
      DRb.start_service
      ts = DRbObject.new_with_uri("druby://#{host}")

      loop do
        pthread_id, _, code, context = ts.take([nil, queue, nil, nil])

        context && context.each do |a, v|
          singleton_class.class_eval { attr_accessor a }
          self.send("#{a}=", context[a])
        end

        value = begin
          eval(code)
        rescue => e
          e
        end

        ts.write([pthread_id, value])
      end
    rescue DRb::DRbConnError
      exit 0
    end
  end
end