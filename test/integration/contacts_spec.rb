require_relative "../test_helper"

describe Contact do
  fixtures :all

  it "requires a user and name" do
    Contact.new.valid?.should == false
    users(:joe).contacts.new(name: "Dallas").valid?.should == true
  end
  
  it "should be unique" do
    joe = users(:joe)

    2.times do
      joe.contacts.create(name: "Same Same", data: { same: :same })
    end
    
    joe.contacts.count.should == 1
  end
  
  it "data changes are overwriteable" do
    data = { "awesome" => "cool" }
    joe = users(:joe)
    contact = contacts(:valid)
    contact.update_column :user_id, joe.id
    contact.update_attributes data: data, overwrite: true
    contact.pending_data.should == {}
    contact.data.should == data
  end
  
  it "data changes are be ignored if not overwritten explicitly" do
    data = { "awesome" => "cool" }
    joe = users(:joe)
    contact = contacts(:valid)
    contact.update_column :user_id, joe.id
    contact.update_attributes data: data
    contact.pending_data.should == data
    contact.ignore_pending_data
    contact.pending_data.should == {}
  end
  
  it "pending data can be written" do
    pending_data = { "awesome" => "cool" }
    joe = users(:joe)
    contact = contacts(:valid)
    contact.update_column :user_id, joe.id
    contact.data = pending_data
    contact.save
    contact.write_pending_data
    contact.data.should == pending_data
    contact.pending_data.should == {}
  end
end