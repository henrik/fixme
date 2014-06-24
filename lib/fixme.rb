require "fixme/version"
require "date"

module Fixme
  class UnfixedError < StandardError; end

  module Mixin
    def FIXME(date_and_message)
      # In a separate class to avoid mixing in privates.
      # http://thepugautomatic.com/2014/02/private-api/
      Runner.new(date_and_message).run
    end
  end

  class Runner
    RUN_ONLY_IN_FRAMEWORK_ENVS = [ "", "test", "development" ]

    def initialize(date_and_message)
      @date_and_message = date_and_message
    end

    def run
      return if ENV["DO_NOT_RAISE_FIXMES"]
      return unless RUN_ONLY_IN_FRAMEWORK_ENVS.include?(framework_env)

      due_date, message = parse

      disallow_timecop do
        if Date.today >= due_date
          raise UnfixedError, "Fix by #{due_date}: #{message}"
        end
      end
    end

    private

    def framework_env
      defined?(Rails) ? Rails.env.to_s : ENV["RACK_ENV"]
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
