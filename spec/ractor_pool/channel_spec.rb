# frozen_string_literal: true

RSpec.describe RactorPool::Channel do
  describe 'publishing and subscribing 1' do
    it 'sends data to the other side' do
      channel = described_class.new

      receiver = Ractor.new(channel) do |channel|
        channel.subscribe do |data|
          Ractor.yield(data)
        end
      end

      sender = Ractor.new(channel) do |channel|
        channel << { test: :data }
        channel.close!
      end

      sender.take

      expect(receiver.take).to eq({ test: :data })
    end
  end
end
