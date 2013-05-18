require 'spec_helper'

describe Pthread::Pthread do

  let(:x) { 5 }

  let(:pthread) do
    Pthread::Pthread.new queue: 'tasks', code: %{
      25 / x
    }, context: { x: x }
  end

  before do
    Pthread::Pthread.start_service 'localhost:12345'
    Pthread::Pthread.add_executor 'tasks'
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
end