# frozen_string_literal: true

RSpec.describe RactorPool::Pool do
  describe '.start' do
    it 'works' do
      handler = Class.new do
        class << self
          def call(value, **_params)
            { value: value }
          end
        end
      end

      pool = described_class.new(jobs: Etc.nprocessors)
      pool.start
      (0..100).each do |n|
        pool.schedule(handler, n)
      end
      results = pool.stop
      sum = results.reduce(0) { |n, result| n + result[:result][:value] }
      expect(sum).to eq(5050)
    end
  end
end
