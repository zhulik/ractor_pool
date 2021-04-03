# frozen_string_literal: true

class RactorPool::Pool
  def initialize(jobs:, mapper_class:, reducer_class:)
    @jobs = jobs
    @logger = Logger.new($stdout)
    @mapper_class = mapper_class
    @reducer_class = reducer_class
  end

  def start
    reducer
    workers
    self
  end

  def schedule(*args, **params)
    jobs_pipe << { type: :job, args: args, params: params }
    self
  end

  def stop
    jobs_pipe.close!
    workers.each(&:take)
    results_pipe.close!
    result = reducer.take
    instance_variable_set(:@jobs_pipe, nil)
    instance_variable_set(:@resuts_pipe, nil)
    instance_variable_set(:@workers, nil)
    instance_variable_set(:@reducer, nil)
    result
  end

  private

  def jobs_pipe
    @jobs_pipe ||= RactorPool::Channel.new
  end

  def results_pipe
    @results_pipe ||= RactorPool::Channel.new
  end

  def workers # rubocop:disable Metrics/MethodLength
    @workers ||= (1..@jobs).map do |worker_id|
      Ractor.new(worker_id, jobs_pipe, results_pipe, @mapper_class,
                 @logger) do |worker_id, jobs_pipe, results_pipe, mapper_class, logger|
        logger.debug("Worker #{worker_id}: started")
        jobs_pipe.subscribe do |data|
          logger.debug("Worker #{worker_id}: received data: #{data}")
          case data
          in args: args, params: params
            logger.debug("Worker #{worker_id}: running #{mapper_class}.call(*#{args}, **#{params}))")
            results_pipe << { type: :result, worker_id: worker_id, args: args, params: params,
                              result: mapper_class.call(logger, *args, **params) }
          else
            logger.debug("Worker #{worker_id}: Unknown data received: #{msg}")
          end
        end
      end
    end
  end

  def reducer
    @reducer ||= Ractor.new(results_pipe, @logger, @reducer_class) do |results_pipe, logger, reducer_class|
      logger.debug('Reducer: started')

      reducer = reducer_class.new(logger: logger)
      result = nil
      results_pipe.subscribe do |data|
        logger.debug("Reducer: received data: #{data}")
        result = reducer.call(**data)
      end
      Ractor.yield(result)
    end
  end
end
