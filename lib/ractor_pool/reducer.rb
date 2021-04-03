# frozen_string_literal: true

class RactorPool::Reducer
  attr_accessor :value

  def initialize(logger:)
    @logger = logger
  end

  def initial_state
    raise NotImplementedError
  end

  private

  attr_reader :logger
end
