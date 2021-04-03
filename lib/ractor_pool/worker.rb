# frozen_string_literal: true

class RactorPool::Worker
  def initialize(*args)
    # logger = Logger.new($stdout)
    Ractor.new(args + [@logger]) do |worker_id, jobs_pipe, _results_pipe, logger|
      jobs_pipe.subscribe do |data|
        logger.debug("Worker #{worker_id}: received data: #{data}")
        yield(data)
      end
    end
  end
end
