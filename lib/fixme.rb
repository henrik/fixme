require "fixme/version"
require "date"

module Fixme
  UnfixedError = Class.new(StandardError)

  Details = Struct.new(:conditional, :backtrace) do
    def method_missing(name, *args)
      if conditional.respond_to?(name)
        conditional.send(name, *args)
      else
        super
      end
    end
  end

  DEFAULT_EXPLODER = ->(details) { raise(UnfixedError, details.full_message, details.backtrace) }

  def self.explode_with(&block)
    @explode_with = block
  end

  def self.explode(conditional)
    backtrace = caller.reverse.take_while { |line| !line.include?(__FILE__) }.reverse
    @explode_with.call Details.new(conditional, backtrace)
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

      conditional = parse

      disallow_timecop do
        Fixme.explode(conditional) if conditional.true?
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
      DateConditional.new(raw_date, message)
    end
  end

  class DateConditional
    attr_reader :date, :message

    def initialize(raw_date, message)
      @date = Date.parse(raw_date)
      @message = message
    end

    def true?
      Date.today >= date
    end

    def full_message
      "Fix by #{date}: #{message}"
    end

    def due_days_ago
      (Date.today - date).to_i
    end
  end
end

Object.include(Fixme::Mixin)
