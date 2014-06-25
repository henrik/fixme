require "fixme/version"
require "date"

module Fixme
  class UnfixedError < StandardError; end

  DEFAULT_EXPLODER = proc { |message| raise(UnfixedError, message) }

  def self.reset_configuration
    explode_with(&DEFAULT_EXPLODER)
  end

  def self.explode_with(&block)
    @explode_with = block
  end

  def self.explode(date, message)
    full_message = "Fix by #{date}: #{message}"
    @explode_with.call(full_message, date, message)
  end

  reset_configuration
end

module Fixme
  module Mixin
    def FIXME(date_and_message)
      # In a separate class to avoid mixing in privates.
      # http://thepugautomatic.com/2014/02/private-api/
      Runner.new(date_and_message).run
    end
  end

  class Runner
    RUN_ONLY_IN_THESE_FRAMEWORK_ENVS = [ "", "test", "development" ]

    def initialize(date_and_message)
      @date_and_message = date_and_message
    end

    def run
      return if ENV["DISABLE_FIXME_LIB"]
      return unless RUN_ONLY_IN_THESE_FRAMEWORK_ENVS.include?(framework_env.to_s)

      due_date, message = parse

      disallow_timecop do
        Fixme.explode(due_date, message) if Date.today >= due_date
      end
    end

    private

    def framework_env
      defined?(Rails) ? Rails.env : ENV["RACK_ENV"]
    end

    def disallow_timecop(&block)
      if defined?(Timecop)
        Timecop.return(&block)
      else
        block.call
      end
    end

    def parse
      raw_date, message = @date_and_message.split(": ", 2)
      [ Date.parse(raw_date), message ]
    end
  end
end

Object.include(Fixme::Mixin)
