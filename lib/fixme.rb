require "fixme/version"
require "date"

module Fixme
  class UnfixedError < StandardError; end

  module Mixin
    def FIXME(date_and_message)
      return if ENV["DO_NOT_RAISE_FIXMES"]

      env = defined?(Rails) ? Rails.env : ENV["RACK_ENV"]
      return unless [ "", "test", "development" ].include?(env.to_s)

      raw_date, message = date_and_message.split(": ", 2)
      due_date = Date.parse(raw_date)

      raise_if_due = -> {
        if Date.today >= due_date
          raise UnfixedError, "Fix by #{due_date}: #{message}"
        end
      }

      if defined?(Timecop)
        Timecop.return(&raise_if_due)
      else
        raise_if_due.call
      end
    end
  end
end

Object.include(Fixme::Mixin)
