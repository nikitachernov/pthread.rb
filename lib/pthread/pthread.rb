require 'rinda/tuplespace'

class Pthread::Pthread
  @@ts  = Rinda::TupleSpace.new
  @@pids = []

  def self.start_service(host)
    @@host = host
    DRb.start_service("druby://#{@@host}", @@ts)
  end

  def self.add_executors(count = 1, queue=nil)
    count.times do
      @@pids << fork do
        DRb.stop_service
        Pthread::PthreadExecutor.new(@@host, queue)
      end
    end
  end

  def self.add_executor(queue=nil)
    add_executors(1, queue)
  end

  def self.kill_executors
    Process.kill 'HUP', *@@pids
  end

  def initialize(job)
    @@ts.write([self.object_id, job[:queue], job[:code], job[:context]])
  end

  def value
    raw_value.is_a?(StandardError) ? raise(raw_value) : raw_value
  end

private

  def raw_value
    @raw_value ||= @@ts.take([self.object_id, nil])[1]
  end
end