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

  # Had a bug with ": " in the message.
  it "parses the date and message flawlessly" do
    expect {
      FIXME "2013-12-31: Remove this: and this."
    }.to raise_error("Fix by 2013-12-31: Remove this: and this.")
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
      stub_env "DO_NOT_RAISE_FIXMES", nil
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

  it "does not raise when the DO_NOT_RAISE_FIXMES environment variable is set" do
    stub_env "DO_NOT_RAISE_FIXMES", true
    expect_not_to_raise
  end

  context "configuring an alternative to raising" do
    it "lets you provide a block" do
      log = []

      Fixme.explode_with do |full_message, date, message|
        log << [ full_message, date, message ]
      end

      FIXME "2013-12-31: Do not explode."

      expect(log.last).to eq [
        "Fix by 2013-12-31: Do not explode.",
        Date.new(2013, 12, 31),
        "Do not explode.",
      ]
    end

    it "lets the block take a subset of parameters" do
      log = []

      Fixme.explode_with do |full_message|
        log << full_message
      end

      FIXME "2013-12-31: Do not explode."

      expect(log.last).to eq "Fix by 2013-12-31: Do not explode."
    end
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
