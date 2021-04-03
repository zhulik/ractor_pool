# frozen_string_literal: true

class RactorPool::Reducers::CollectReducer < RactorPool::Reducer
  def initialize(logger:)
    super(logger: logger)
    @data = []
  end

  def reduce(**args)
    @logger.debug("Reducer received: #{args}")
    @data << args
  end
end
