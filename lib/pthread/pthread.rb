require 'rinda/tuplespace'

module Pthread

  # The +Pthread+ class is the main class that users work with.
  # It used for creating forks to be executed in a separate processes
  # including on remote machines.
  class Pthread

    @@ts   = Rinda::TupleSpace.new
    @@pids = []

    # Starts the drb server.
    #
    # @param [String] host that contains host url and port.
    #
    # @example Start service
    #   Pthread::Pthread.start_service '192.168.1.100:12345'
    def self.start_service(host)
      @@host = host
      DRb.start_service("druby://#{@@host}", @@ts)
    end

    # Adds executors on the same machine as the main programm.
    #
    # @param [FixNum] count amount of executors to start.
    # @param [Symbol, String] queue name of the queue for executors to be attached to.
    #
    # @example Add executors without a queue
    #   Pthread::Pthread.add_executors 5
    # @example Add executors for specific queue
    #   Pthread::Pthread.add_executors 5, :tasks
    def self.add_executors(count = 1, queue=nil)
      count.times do
        @@pids << fork do
          DRb.stop_service
          PthreadExecutor.new(@@host, queue)
        end
      end
    end

    # Adds a single executor on the same machine as the main programm.
    #
    # @param [Symbol, String] queue name of the queue for executor to be attached to.
    #
    # @example Add an executor without a queue
    #   Pthread::Pthread.add_executor
    # @example Add an executor for a specific queue
    #   Pthread::Pthread.add_executor, :tasks
    def self.add_executor(queue=nil)
      add_executors(1, queue)
    end

    # Kills all launched executors on this machine.
    #
    # @example Add executors without a queue
    #   Pthread::Pthread.kill_executors
    def self.kill_executors
      Process.kill 'HUP', *@@pids
      @@pids = []
    end

    # Initializes new pthread and schedules execution of the job.
    #
    # @param [Hash] job should contain :code, :context and optionally :queue
    # 
    # @example Initialize new parrallel job
    #   pthread = Pthread::Pthread.new queue: 'tasks', code: %{
    #     x ** 2
    #   }, context: { x: 5 }
    def initialize(job)
      @@ts.write([self.object_id, job[:queue], job[:code], job[:context]])
    end


    # Returns value of a pthread.
    #
    # @note If value is not yet calculated it will block the execution.
    # @note If pthread resulted in an exception it will be raised.
    #
    # @example
    #  pthread.value
    #
    # @return [Object] value of a pthread.
    def value
      raw_value.is_a?(StandardError) ? raise(raw_value) : raw_value
    end

  private

    # Returns raw value of a pthread even if it was an exception.
    #
    # @note If value is not yet calculated will block the execution.
    #
    # @return [Object] raw value of a pthread.
    def raw_value
      @raw_value ||= @@ts.take([self.object_id, nil])[1]
    end
  end
end