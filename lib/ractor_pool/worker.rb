# frozen_string_literal: true

class RactorPool::Worker
  def initialize(*args)
    Ractor.new(args) do |worker_id, jobs_pipe, _results_pipe, logger|
      # logger = Logger.new($stdout)
      jobs_pipe.subscribe do |data|
        logger.debug("Worker #{worker_id}: received data: #{data}")
        yield(data, logger)
      end
    end
  end
end
