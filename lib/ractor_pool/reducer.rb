# frozen_string_literal: true

class RactorPool::Reducer
  attr_reader :value, :logger

  def initialize(logger:)
    @logger = logger
    @value = initial_value
  end

  def initial_value
    raise NotImplementedError
  end

  private

  attr_writer :value
end
