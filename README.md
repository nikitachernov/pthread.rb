# Pthread

Module Pthread provides possibility for Ruby to run pieces of code in parallel using additional Unix processes on the same or other machines in the network.

[![Build Status](https://travis-ci.org/nikitachernov/Pthread.png)](https://travis-ci.org/nikitachernov/Pthread)

## Installation

Add this line to your application's Gemfile:

    gem 'pthread'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pthread

## Usage

Before using parallel threads you should configure a dRb server:

    Pthread::Pthread.start_service '192.168.1.100:12345'

Pthreads are actual Unix processes. You can add process-workers on the same machine as the main programm by calling:

    Pthread::Pthread.add_executor 'tasks'

or

    Pthread::Pthread.add_executors 5, 'tasks'

Methods #add_executor and #add_executors take an optional parameter that specifies a queue name.

In order to connect an executor from a separate machine in your programm you can call:

    Pthread::PthreadExecutor.new '192.168.1.100:12345', 'tasks'

specifing the host and a desired queue.

Now you can spawn Pthreads in order to gain multicore performance by providing name of the queue, code to be executed and context variables:

    Pthread::Pthread.new queue: 'tasks', code: %{
      x ** 2
    }, context: { x: 5 }

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
