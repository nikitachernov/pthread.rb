require 'spec_helper'

describe Pthread::Pthread do

  before(:all) do
    Pthread::Pthread.start_service 'localhost:54321'
    Pthread::Pthread.add_executor 'tasks'
  end

  let(:x) { 5 }

  let(:pthread) do
    Pthread::Pthread.new queue: 'tasks', code: %{
      25 / x
    }, context: { x: x }
  end

  context 'without exceptions' do
    it 'should calculate value in a separate process' do
      pthread.value.should eq 5
    end
  end

  context 'with exceptions' do
    let(:x) { 0 }

    it 'should store exception' do
      pthread.send(:raw_value).should be_instance_of ZeroDivisionError
    end

    it 'should raise error on value access' do
      expect { pthread.value }.to raise_error ZeroDivisionError
    end
  end

  after(:all) do
    Pthread::Pthread.kill_executors
  end
end