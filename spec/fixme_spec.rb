require "fixme"

describe Fixme, "#TODO" do
  it "raises after the given date" do
    expect {
      FIXME "2013-12-31: Remove this stuff."
    }.to raise_error(Fixme::UnfixedError, "Fix by 2013-12-31: Remove this stuff.")
  end

  it "raises on the given date" do
    expect {
      FIXME "#{Date.today.to_s}: Remove this stuff."
    }.to raise_error(Fixme::UnfixedError, "Fix by #{Date.today.to_s}: Remove this stuff.")
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

  context "when a Rails environment is detected" do
    before do
      stub_const("Rails", double)
    end

    it "raises in the 'test' environment" do
      Rails.stub(env: "test")
      expect_to_raise
    end

    it "raises in the 'development' environment" do
      Rails.stub(env: "development")
      expect_to_raise
    end

    it "does not raise in other environments" do
      Rails.stub(env: "production")
      expect_not_to_raise
    end
  end

  context "when a Rack environment is detected" do
    it "raises in the 'test' environment" do
      ENV.stub(:[]).with("RACK_ENV").and_return("test")
      expect_to_raise
    end

    it "raises in the 'development' environment" do
      ENV.stub(:[]).with("RACK_ENV").and_return("development")
      expect_to_raise
    end

    it "does not raise in other environments" do
      ENV.stub(:[]).with("RACK_ENV").and_return("production")
      expect_not_to_raise
    end
  end

  private

  def expect_to_raise
    expect { FIXME "2013-12-31: X" }.to raise_error(Fixme::UnfixedError)
  end

  def expect_not_to_raise
    expect { FIXME "2013-12-31: X" }.not_to raise_error
  end
end
