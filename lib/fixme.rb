require "fixme/version"
require "date"

module Fixme
  UnfixedError = Class.new(StandardError)

  Details = Struct.new(:full_message, :backtrace, :date, :message) do
    def due_days_ago
      (Date.today - date).to_i
    end
  end

  DEFAULT_EXPLODER = ->(details) { raise(UnfixedError, details.full_message, details.backtrace) }

  def self.explode_with(&block)
    @explode_with = block
  end

  def self.explode(date, message)
    full_message = "Fix by #{date}: #{message}"
    backtrace = caller.reverse.take_while { |line| !line.include?(__FILE__) }.reverse
    @explode_with.call Details.new(full_message, backtrace, date, message)
  end

  def self.raise_from(details)
    DEFAULT_EXPLODER.call(details)
  end

  def self.reset_configuration
    explode_with(&DEFAULT_EXPLODER)
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
      match = @date_and_message.match(/\A(\d\d\d\d-\d\d?-\d\d?): (.+)\z/)

      unless match
        raise %{FIXME does not follow the "2015-01-01: Foo" format: #{@date_and_message.inspect}}
      end

      raw_date, message = match.captures
      [ Date.parse(raw_date), message ]
    end
  end
end

Object.include(Fixme::Mixin)
