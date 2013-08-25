require_relative "../test_helper"

describe Email do
  fixtures :all
  
  before :each do
    EmailWorker.jobs.clear
  end

  it "requires a subject and body" do
    Email.new.valid?.should == false
    users(:joe).update_attributes address: "yo"
    users(:joe).emails.new(subject: "Subject", plain: "Body", criteria: []).valid?.should == true
  end
  
  it "sends the emails" do
    simple = emails(:simple)
    simple.prepare_to_deliver
    
    EmailWorker.jobs.size.should == 1
    ActionMailer::Base.deliveries.should == []
    
    EmailWorker.drain
    ActionMailer::Base.deliveries.size.should == 3
    
    mail = ActionMailer::Base.deliveries.last
    last_contact = simple.user.contacts.last
    mail.from.to_s.should include simple.user.email
    mail.body.to_s.should include "body"
    mail.body.to_s.should include last_contact.name
    mail.body.to_s.should include subscription_path(last_contact.token)
    
    simple.tasks.complete.count.should == 3
    simple.user.tasks.complete.count.should == 3
  end
  
  it "can be unsubscribed" do
    john = contacts(:birthday_a_week_ago)
    john.emailable.should == true
    
    visit subscription_url(john.token)
    page.should have_content "unsubscribed"
    john.reload.emailable.should == false
    
    visit subscription_url(john.token)
    page.should have_content "re-subscribed"
    john.reload.emailable.should == true
  end
  
  it "can't be unsubscribed without a valid token" do
    visit subscription_url("invalid")
    page.should have_content "identify"
  end
end