# frozen_string_literal: true

class RactorPool::Reducer
  attr_reader :result, :logger

  def initialize(logger:)
    @logger = logger
    @result = initial_value
  end

  def initial_value
    raise NotImplementedError
  end
end
