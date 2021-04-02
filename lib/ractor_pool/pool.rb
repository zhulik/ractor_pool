# frozen_string_literal: true

class RactorPool::Pool
  def initialize(jobs:)
    @jobs = jobs
  end

  def start
    reducer
    workers
    self
  end

  def schedule(klass, *args, **params)
    jobs_pipe << { type: :job, klass: klass, args: args, params: params }
    self
  end

  def stop
    jobs_pipe << { type: :stop }
    workers.each(&:take)
    results_pipe << { type: :stop }
    result = reducer.take
    instance_variable_set(:@jobs_pipe, nil)
    instance_variable_set(:@resuts_pipe, nil)
    instance_variable_set(:@workers, nil)
    instance_variable_set(:@reducer, nil)
    result
  end

  private

  def jobs_pipe # rubocop:disable Metrics/MethodLength
    @jobs_pipe ||= Ractor.new(@jobs) do |jobs|
      logger = Logger.new($stdout)
      loop do
        msg = Ractor.recv
        logger.debug("Jobs pipe received message: #{msg}")
        case msg
        in type: :stop
          logger.debug('Jobs pipe stopping...')
          jobs.times { Ractor.yield(msg) }
        else
          Ractor.yield(msg)
        end
      end
    end
  end

  def results_pipe # rubocop:disable Metrics/MethodLength
    @results_pipe ||= Ractor.new(@jobs) do |jobs|
      logger = Logger.new($stdout)
      loop do
        msg = Ractor.recv
        logger.debug("Results pipe received message: #{msg}")
        case msg
        in type: :stop
          logger.debug('Results pipe stopping...')
          jobs.times { Ractor.yield(msg) }
        else
          Ractor.yield(msg)
        end
      end
    end
  end

  def workers # rubocop:disable Metrics/MethodLength
    @workers ||= (1..@jobs).map do |worker_id|
      Ractor.new(worker_id, jobs_pipe, results_pipe) do |worker_id, jobs_pipe, results_pipe|
        logger = Logger.new($stdout)
        logger.debug("Worker #{worker_id}: started")
        loop do
          msg = jobs_pipe.take
          logger.debug("Worker #{worker_id}: received message: #{msg}")
          case msg
          in type: :stop
            break logger.debug("Worker #{worker_id}: stopping...")
          in type: :job, klass: klass, args: args, params: params
            logger.debug("Worker #{worker_id}: running #{klass}.call(*#{args}, **#{params}))")
            results_pipe << { type: :result, worker_id: worker_id, klass: klass, args: args, params: params,
                              result: klass.call(*args, **params) }
          else
            logger.debug("Worker #{worker_id}: Unknown message received: #{msg}")
          end
        end
      end
    end
  end

  def reducer  # rubocop:disable Metrics/MethodLength
    @reducer ||= Ractor.new(results_pipe) do |results_pipe|
      logger = Logger.new($stdout)
      logger.debug('Reducer: started')

      reducer = RactorPool::Reducer.new(logger)
      loop do
        msg = results_pipe.take
        logger.debug("Reducer: received message: #{msg}")
        case msg
        in type: :stop
          logger.debug('Reducer: stopping...')
          Ractor.yield(reducer.result)
          break
        in type: :result
          logger.debug("Redcuer: reducing #{msg})")
          reducer.reduce(**msg)
        else
          logger.debug("Reducer: Unknown message received: #{msg}")
        end
      end
    end
  end
end
