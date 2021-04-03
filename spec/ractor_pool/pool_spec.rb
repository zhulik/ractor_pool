# frozen_string_literal: true

RSpec.describe RactorPool::Pool do
  describe '.start' do
    it 'works' do
      mapper = Class.new(RactorPool::Mapper) do
        def call(value, **_params)
          value
        end
      end

      pool = described_class.new(jobs: Etc.nprocessors, mapper: mapper)
      pool.start
      (0..100).each do |n|
        pool.schedule(n)
      end
      results = pool.stop
      sum = results.reduce(0) { |n, result| n + result[:result] }
      expect(sum).to eq(5050)
    end
  end
end
