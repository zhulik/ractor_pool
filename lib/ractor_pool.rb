# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem

loader.setup

require 'logger'

class RactorPool::Error < StandardError
end

module RactorPool
  class << self
    def new(jobs: Etc.nprocessors)
      Pool.new(jobs: jobs)
    end
  end
end
