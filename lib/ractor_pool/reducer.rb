# frozen_string_literal: true

class RactorPool::Reducer
  attr_reader :result, :logger

  def initialize(logger:)
    @logger = logger
  end
end
