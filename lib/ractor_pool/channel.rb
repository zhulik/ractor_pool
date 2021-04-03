# frozen_string_literal: true

class RactorPool::Channel
  def initialize # rubocop:disable Metrics/MethodLength
    @pipe = Ractor.new do
      listeners_count = 0
      loop do
        msg = Ractor.recv
        case msg
        in type: :close
          listeners_count.times { Ractor.yield(msg) }
          break
        in type: :subscription
          listeners_count += 1
          Ractor.yield({ type: :skip })
        in type: :data
          Ractor.yield({ type: :data, data: msg[:data] })
        else
        end
      end
    end
  end

  def <<(data)
    @pipe.send({ type: :data, data: data })
  end

  def close!
    @pipe.send({ type: :close }, move: true)
  end

  def subscribe
    @pipe.send({ type: :subscription }, move: true)
    loop do
      msg = @pipe.take
      case msg
        in type: :close
        return
        in type: :data
        yield(msg[:data])
        else
      end
    end
  rescue Ractor::ClosedError # rubocop:disable Lint/SuppressedException
  end
end
