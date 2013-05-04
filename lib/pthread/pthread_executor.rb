require 'drb/drb'

class Pthread::PthreadExecutor
  def initialize(host, queue=nil)
    DRb.start_service
    ts = DRbObject.new_with_uri("druby://#{host}")

    loop do
      pthread_id, _, code, context = ts.take([nil, queue, nil, nil])

      context && context.each do |a, v|
        singleton_class.class_eval { attr_accessor a }
        self.send("#{a}=", context[a])
      end

      ts.write([pthread_id, eval(code)])
    end
  rescue DRb::DRbConnError
    exit 0
  end
end