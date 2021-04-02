# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem

loader.setup
loader.eager_load

class RactorPool::Error < StandardError
end
