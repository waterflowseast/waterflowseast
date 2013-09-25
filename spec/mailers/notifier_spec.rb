require "spec_helper"

describe Notifier do
  describe "send_invitation" do
    let(:mail) { Notifier.send_invitation }

    it "renders the headers" do
      mail.subject.should eq("Send invitation")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

  describe "send_email_confirm" do
    let(:mail) { Notifier.send_email_confirm }

    it "renders the headers" do
      mail.subject.should eq("Send email confirm")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

  describe "send_password_reset" do
    let(:mail) { Notifier.send_password_reset }

    it "renders the headers" do
      mail.subject.should eq("Send password reset")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
