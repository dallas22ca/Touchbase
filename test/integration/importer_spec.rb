require_relative "../test_helper"

describe Importer do
  fixtures :all
  
  it "can import contacts with headers" do
    joe = users(:joe)
    path = "#{Rails.root}/test/assets/4withheaders.csv"
    importer = Importer.new(joe.id, "file", path).import
    joe.contacts.count.should == 4
    joe.contacts.first.name.should == "Dallas Read"
    importer[:success].should == true
  end
  
  it "can import contacts without headers" do
    joe = users(:joe)
    path = "#{Rails.root}/test/assets/4withoutheaders.csv"
    importer = Importer.new(joe.id, "file", path).import
    joe.contacts.count.should == 0
    importer[:success].should == false
  end
  
  it "ignores identical duplicate contacts" do
    joe = users(:joe)
    path = "#{Rails.root}/test/assets/2duplicates.csv"
    importer = Importer.new(joe.id, "file", path).import
    importer[:warnings].to_s.should include "duplicate"
    importer[:success].should == true
    joe.contacts.count.should == 1
    joe.contacts.first.name.should == "Dallas Read"
  end
  
  it "prompts when duplicate is uploaded" do
    joe = users(:joe)
    path = "#{Rails.root}/test/assets/2duplicateswithnewinfo.csv"
    importer = Importer.new(joe.id, "file", path).import
    importer[:warnings].to_s.should include "pending"
    importer[:success].should == true
    joe.contacts.first.data["address"].should == "2846 Andorra Circle"
    joe.contacts.count.should == 1
    joe.contacts.pending.count.should == 1
  end
  
  it "overwrites when asked to" do
    joe = users(:joe)
    path = "#{Rails.root}/test/assets/2duplicateswithnewinfo.csv"
    importer = Importer.new(joe.id, "file", path, true).import
    importer[:warnings].empty?.should == true
    importer[:success].should == true
    joe.contacts.first.data["address"].should == "61 Westfield Crescent"
    joe.contacts.count.should == 1
    joe.contacts.pending.count.should == 0
  end
  
  it "adds fields to the user" do
    joe = users(:joe)
    path = "#{Rails.root}/test/assets/4withheaders.csv"
    importer = Importer.new(joe.id, "file", path).import
    joe.fields.count.should == 2
  end
  
  it "adds contacts via plain text" do
    joe = users(:joe)
    blob = "
Name, Email, Address
Dallas Read, dallasgood@gmail.com, 61 Westfield Crescent
Melanie Read, melaniegood@gmail.com, 61 Westfield Crescent
"
    joe.update_column :blob, blob
    importer = Importer.new(joe.id, "blob").import
    joe.contacts.count.should == 2
  end
  
end
