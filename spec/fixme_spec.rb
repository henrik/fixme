require "fixme"
require "timecop"

describe Fixme, "#FIXME" do
  before do
    Fixme.reset_configuration
  end

  it "raises after the given date" do
    expect {
      FIXME "2013-12-31: Remove this stuff."
    }.to raise_error(Fixme::UnfixedError, "Fix by 2013-12-31: Remove this stuff.")
  end

  it "raises on the given date" do
    today = Date.today

    expect {
      FIXME "#{today}: Remove this stuff."
    }.to raise_error(Fixme::UnfixedError, "Fix by #{today}: Remove this stuff.")
  end

  it "does not raise before the given date" do
    expect {
      FIXME "9999-01-01: Upgrade to Ruby 641.3.1."
    }.not_to raise_error
  end

  it "truncates the backtrace to exclude the library itself" do
    begin
      FIXME "2013-12-31: Remove this stuff."
    rescue => e
      expect(e.backtrace.first).to include("fixme_spec.rb:")
    end
  end

  # Had a bug with ": " in the message.
  it "parses the date and message flawlessly" do
    expect {
      FIXME "2013-12-31: Remove this: and this."
    }.to raise_error("Fix by 2013-12-31: Remove this: and this.")
  end

  it "complains if the desired format is not adhered to" do
    expect {
      FIXME "9999-01-01, Learn to: type"
    }.to raise_error(%{FIXME does not follow the "2015-01-01: Foo" format: "9999-01-01, Learn to: type"})
  end

  it "is available everywhere" do
    expect {
      "some random object".instance_eval do
        FIXME "2013-12-31: Make it work everywhere."
      end
    }.to raise_error(Fixme::UnfixedError)
  end

  it "is not fooled by the Timecop gem" do
    future_date = Date.today + 2

    Timecop.travel(future_date) do
      expect {
        FIXME "#{future_date}: Travel back in time."
      }.not_to raise_error
    end
  end

  context "when a Rails environment is detected" do
    before do
      stub_const("Rails", double)
    end

    it "raises in the 'test' environment" do
      stub_rails_env "test"
      expect_to_raise
    end

    it "raises in the 'development' environment" do
      stub_rails_env "development"
      expect_to_raise
    end

    it "does not raise in other environments" do
      stub_rails_env "production"
      expect_not_to_raise
    end
  end

  context "when a Rack environment is detected" do
    before do
      stub_env "DISABLE_FIXME_LIB", nil
    end

    it "raises in the 'test' environment" do
      stub_env "RACK_ENV", "test"
      expect_to_raise
    end

    it "raises in the 'development' environment" do
      stub_env "RACK_ENV", "development"
      expect_to_raise
    end

    it "does not raise in other environments" do
      stub_env "RACK_ENV", "production"
      expect_not_to_raise
    end
  end

  it "does not raise when the DISABLE_FIXME_LIB environment variable is set" do
    stub_env "DISABLE_FIXME_LIB", true
    expect_not_to_raise
  end

  it "lets you configure an alternative to raising" do
    log = nil

    Fixme.explode_with do |details|
      log = details
    end

    FIXME "2013-12-31: Do not explode."

    expect(log.full_message).to eq "Fix by 2013-12-31: Do not explode."
    expect(log.date).to eq Date.new(2013, 12, 31)
    expect(log.message).to eq "Do not explode."
    expect(log.backtrace.first).to include "fixme_spec.rb:"

    expect(log.due_days_ago).to eq(Date.today - log.date)
    expect(log.due_days_ago).to be > 0
  end

  it "lets you use Fixme.raise_from in configuration" do
    Fixme.explode_with do |details|
      Fixme.raise_from(details)
    end

    expect {
      FIXME "2013-12-31: Do not explode."
    }.to raise_error(Fixme::UnfixedError, "Fix by 2013-12-31: Do not explode.")
  end

  private

  def stub_rails_env(value)
    allow(Rails).to receive(:env).and_return(value)
  end

  def stub_env(name, value)
    allow(ENV).to receive(:[]).with(name).and_return(value)
  end

  def expect_to_raise
    expect { FIXME "2013-12-31: X" }.to raise_error(Fixme::UnfixedError)
  end

  def expect_not_to_raise
    expect { FIXME "2013-12-31: X" }.not_to raise_error
  end
end
