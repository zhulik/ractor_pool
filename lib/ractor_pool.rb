# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem

loader.setup

require 'logger'

module RactorPool
  class << self
    def new(mapper_class:, reducer_class: RactorPool::Reducers::CollectReducer, jobs: Etc.nprocessors)
      Pool.new(jobs: jobs, mapper_class: mapper_class, reducer_class: reducer_class)
    end
  end
end

class RactorPool::Error < StandardError
end
