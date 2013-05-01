require 'spec_helper'

describe Pthread::Pthread do

  let(:pthread) do
    Pthread::Pthread.new queue: 'tasks', code: %{
      x ** 2
    }, context: { x: 5 }
  end

  before do
    Pthread::Pthread.start_service 'localhost:12345'
    Pthread::Pthread.add_executor 'tasks'
  end

  it 'should calculate value in a separate process' do
    pthread.value.should eq 25
  end
end