# frozen_string_literal: true

class RactorPool::Worker
  def initialize(logger: Logger.new($stdout))
    @logger = logger
  end

  private

  attr_reader :logger
end
