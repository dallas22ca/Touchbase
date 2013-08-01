require_relative "../test_helper"

describe Contact do
  fixtures :all

  it "requires a user and name" do
    Contact.new.valid?.should == false
    contacts(:valid).valid?.should == true
  end
  
  it "pending changes can be ignored" do
    contact = contacts(:valid)
    data = { pending: :data }
    contact.update_attributes pending_data: data
    contact.pending_data.should == data
    contact.ignore_pending_data
    contact.pending_data.should == {}
  end
end