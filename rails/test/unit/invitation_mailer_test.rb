require 'test_helper'

class InvitationMailerTest < ActionMailer::TestCase
  test "thankyou" do
    @expected.subject = 'InvitationMailer#thankyou'
    @expected.body    = read_fixture('thankyou')
    @expected.date    = Time.now

    assert_equal @expected.encoded, InvitationMailer.create_thankyou(@expected.date).encoded
  end

  test "sent" do
    @expected.subject = 'InvitationMailer#sent'
    @expected.body    = read_fixture('sent')
    @expected.date    = Time.now

    assert_equal @expected.encoded, InvitationMailer.create_sent(@expected.date).encoded
  end

end
