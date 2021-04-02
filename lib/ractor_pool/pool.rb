# frozen_string_literal: true

class RactorPool::Pool
  def initialize(jobs:)
    @jobs = jobs
  end

  def start
    workers
    self
  end

  def schedule(klass, **params)
    pipe << { type: :job, class: klass, params: params }
    self
  end

  def stop
    pipe << { type: :stop }
    workers.each(&:take)
    instance_variable_set(:@pipe, nil)
    instance_variable_set(:@workers, nil)
    self
  end

  private

  def pipe # rubocop:disable Metrics/MethodLength
    @pipe ||= Ractor.new(@jobs) do |jobs|
      logger = Logger.new($stdout)
      loop do
        msg = Ractor.recv
        logger.debug("Pipe received message: #{msg}")
        case msg
        in type: :stop
          logger.debug('Pipe stopping...')
          jobs.times { Ractor.yield(msg) }
        else
          Ractor.yield(msg)
        end
      end
    end
  end

  def workers # rubocop:disable Metrics/MethodLength
    @workers ||= (1..@jobs).map do |worker_id|
      Ractor.new(worker_id, pipe) do |worker_id, pipe|
        logger = Logger.new($stdout)
        logger.debug("Worker #{worker_id}: started")
        loop do
          msg = pipe.take
          logger.debug("Worker #{worker_id}: received message: #{msg}")
          case msg
          in type: :stop
            break logger.debug("Worker #{worker_id}: stopping...")
          in type: :job, class: klass, params: params
            logger.debug("Worker #{worker_id}: running #{klass}.call(#{params}))")
            klass.call(**params)
            # TODO: send results back
          else
            logger.debug("Worker #{worker_id}: Unknown message received: #{msg}")
          end
        end
      end
    end
  end
end
