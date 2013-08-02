require_relative "../test_helper"

describe Importer do
  fixtures :all
  
  it "can import contacts with headers" do
    joe = users(:joe)
    path = "#{Rails.root}/test/assets/4withheaders.csv"
    importer = Importer.from_file path, joe.id
    joe.contacts.count.should == 4
    joe.contacts.first.name.should == "Dallas Read"
    importer[:success].should == true
  end
  
  it "can import contacts without headers" do
    joe = users(:joe)
    path = "#{Rails.root}/test/assets/4withoutheaders.csv"
    importer = Importer.from_file path, joe.id
    joe.contacts.count.should == 4
    joe.contacts.first.name.should == "Dallas Read"
    importer[:success].should == true
  end
  
  it "ignores identical duplicate contacts" do
    joe = users(:joe)
    path = "#{Rails.root}/test/assets/2duplicates.csv"
    importer = Importer.from_file path, joe.id
    importer[:warnings].to_s.should include "identical"
    importer[:success].should == true
    joe.contacts.count.should == 1
    joe.contacts.first.name.should == "Dallas Read"
  end
  
  it "prompts when duplicate is uploaded" do
    joe = users(:joe)
    path = "#{Rails.root}/test/assets/2duplicateswithnewinfo.csv"
    importer = Importer.from_file path, joe.id
    importer[:warnings].to_s.should include "pending"
    importer[:success].should == true
    joe.contacts.first.data["address"].should == "2846 Andorra Circle"
    joe.contacts.count.should == 1
    joe.contacts.pending.count.should == 1
  end
  
  it "overwrites when asked to" do
    joe = users(:joe)
    path = "#{Rails.root}/test/assets/2duplicateswithnewinfo.csv"
    importer = Importer.from_file path, joe.id, true
    importer[:warnings].empty?.should == true
    importer[:success].should == true
    joe.contacts.first.data["address"].should == "61 Westfield Crescent"
    joe.contacts.count.should == 1
    joe.contacts.pending.count.should == 0
  end
  
  it "adds fields to the user" do
    joe = users(:joe)
    path = "#{Rails.root}/test/assets/4withheaders.csv"
    importer = Importer.from_file path, joe.id
    joe.fields.count.should == 2
  end
  
end
