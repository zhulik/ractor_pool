# frozen_string_literal: true

RSpec.describe RactorPool::Pool do
  describe '.start' do
    it 'works' do
      mapper = Class.new(RactorPool::Mapper) do
        def call(value, **_params)
          value
        end
      end

      reducer = Class.new(RactorPool::Reducer) do
        def initial_value
          0
        end

        def call(result:, **_params)
          logger.debug("Reducer received: #{result}")
          @result += result
        end
      end

      pool = described_class.new(jobs: Etc.nprocessors, mapper_class: mapper, reducer_class: reducer)
      pool.start
      (0..1000).each do |n|
        pool.schedule(n)
      end
      sum = pool.stop
      expect(sum).to eq(500_500)
    end
  end
end
