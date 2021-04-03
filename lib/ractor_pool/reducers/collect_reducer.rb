# frozen_string_literal: true

class RactorPool::Reducers::CollectReducer < RactorPool::Reducer
  def initial_state
    []
  end

  def call(**args)
    logger.debug("Reducer received: #{args}")
    value << args
    value
  end
end
