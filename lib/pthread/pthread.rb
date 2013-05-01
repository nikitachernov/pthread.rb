require 'rinda/tuplespace'

class Pthread::Pthread
  @@ts = Rinda::TupleSpace.new

  def self.start_service(host)
    @@host = host
    DRb.start_service("druby://#{@@host}", @@ts)
  end

  def self.add_executors(count = 1, queue=nil)
    count.times do
      fork do
        DRb.stop_service
        Pthread::PthreadExecutor.new(@@host, queue)
      end
    end
  end

  def self.add_executor(queue=nil)
    add_executors(1, queue)
  end

  def initialize(job)
    @@ts.write(["#{self.object_id}_s", job[:queue], job[:code], job[:context]])
  end

  def value
    @@ts.take(["#{self.object_id}_r", nil])[1]
  end
end