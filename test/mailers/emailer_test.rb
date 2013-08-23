require 'test_helper'

class EmailerTest < ActionMailer::TestCase
  test "bulk" do
    mail = Emailer.bulk
    assert_equal "Bulk", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
