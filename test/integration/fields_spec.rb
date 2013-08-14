require_relative "../test_helper"

describe Field do
  fixtures :all
  
  before :each do
    ImportWorker.jobs.clear
    Task.destroy_all
  end
  
  it "contacts' anniversary doesn't equal his birthday" do
    field = fields(:birthday)
    contact = contacts(:birthday_in_a_week)
    birthday_content = contact.d["birthday"]
    contact.d["birthday"].to_s.should == birthday_content
    contact.d["anniversary"].to_s.should_not == birthday_content
  end

  it "updates contacts when only field's permalink is changed" do
    field = fields(:birthday)
    contact = contacts(:birthday_in_a_week)
    birthday_content = contact.d["birthday"]
  
    field.update_attributes permalink: "anniversary"
    ImportWorker.drain
    contact.reload
    contact.d["anniversary"].to_s.should == birthday_content
    contact.d["birthday"].to_s.should_not == birthday_content
  end

  it "update contacts when only field's data_type is changed" do
    field = fields(:birthday)
    contact = contacts(:birthday_in_a_week)
    birthday_content = contact.d["birthday"]
  
    field.update_attributes data_type: "boolean"
    ImportWorker.drain
    contact.reload
    contact.d["birthday"].to_s.should == "false"
    contact.d["anniversary"].to_s.should_not == "false"
  end
  
  it "update contacts when field's data_type and permalink are changed" do
    field = fields(:birthday)
    contact = contacts(:birthday_in_a_week)
    birthday_content = contact.d["birthday"]
  
    field.update_attributes data_type: "boolean", permalink: "birthday"
    ImportWorker.drain
    contact.reload
    contact.d["birthday"].to_s.should == "false"
    contact.d["anniversary"].to_s.should_not == "false"
  end
end