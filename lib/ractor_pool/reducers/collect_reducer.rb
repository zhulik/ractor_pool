# frozen_string_literal: true

class RactorPool::Reducers::CollectReducer < RactorPool::Reducer
  def initial_value
    []
  end

  def call(**args)
    logger.debug("Reducer received: #{args}")
    @result << args
  end
end
