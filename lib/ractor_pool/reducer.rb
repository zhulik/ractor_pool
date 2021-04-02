# frozen_string_literal: true

class RactorPool::Reducer
  def initialize(logger)
    @data = []
    @logger = logger
  end

  def reduce(**args)
    @logger.debug("Reducer received: #{args}")
    @data << args
  end

  def result
    @data
  end
end
