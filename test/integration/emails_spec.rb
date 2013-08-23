require_relative "../test_helper"

describe Email do
  fixtures :all
  
  before :each do
    EmailWorker.jobs.clear
  end

  it "requires a subject and body" do
    Email.new.valid?.should == false
    users(:joe).emails.new(subject: "Subject", plain: "Body", criteria: []).valid?.should == true
  end
  
  it "places an email in the emailer" do
    simple = emails(:simple)
    simple.prepare_to_deliver
    EmailWorker.jobs.size.should == 1
    ActionMailer::Base.deliveries.should == []
    EmailWorker.drain
    ActionMailer::Base.deliveries.size.should == 4
    mail = ActionMailer::Base.deliveries.last
    mail.from.to_s.should include simple.user.email
    mail.body.to_s.should include "body"
    mail.body.to_s.should include simple.user.contacts.last.name
  end
  
  # BELONGS TO TASK
end