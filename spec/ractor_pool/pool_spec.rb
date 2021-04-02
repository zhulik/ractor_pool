# frozen_string_literal: true

RSpec.describe RactorPool::Pool do
  describe '.start' do
    it 'works' do
      handler = Class.new do
        class << self
          def call(**_params)
            { hello: :world }
          end
        end
      end

      pool = described_class.new(jobs: Etc.nprocessors)
      pool.start
      (0..10).each do |n|
        pool.schedule(handler, number: n)
      end
      pool.stop
    end
  end
end
