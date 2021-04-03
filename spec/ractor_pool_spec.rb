# frozen_string_literal: true

RSpec.describe RactorPool do
  it 'has a version number' do
    expect(RactorPool::VERSION).not_to be nil
  end

  describe '.new' do
    it 'returns an instance of Pool' do
      expect(described_class.new(mapper_class: nil, reducer_class: nil)).to be_an_instance_of(described_class::Pool)
    end
  end
end
