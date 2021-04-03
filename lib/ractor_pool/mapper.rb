# frozen_string_literal: true

class RactorPool::Mapper
  attr_reader :logger

  def initialize(logger:)
    @logger = logger
  end

  class << self
    def call(logger, *args)
      new(logger: logger).call(*args)
    end
  end
end
