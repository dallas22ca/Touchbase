require_relative "../test_helper"

describe "Filters" do
  fixtures :all
  
  before :each do
    Contact.destroy_all
    joe = users(:joe)
    don   = { "name" => "Don Draper",     "email" => "don@madmen.com",    "paid" => "true",    "number" => 54,   "birthday" => 5.minutes.ago }
    betty = { "name" => "Betty Draper",   "email" => "betty@madmen.com",  "paid" => false,   "number" => 84,   "birthday" => "April 5, 1988" }
    joan  = { "name" => "Joan Hollaway",  "email" => "joan@madmen.com",   "paid" => "t",    "number" => 14,   "birthday" => 5555.days.ago }
    peggy = { "name" => "Peggy Olson",    "email" => "peggy@madmen.com",  "paid" => "f",   "number" => 34,   "birthday" => 365.days.ago }
    
    [don, betty, joan, peggy].each do |character|
      joe.save_contact character
    end
  end
  
  it "operators work for data fields" do
    Contact.all.filter.count.should == 4
    Contact.filter([["email", "is", "joan@madmen.com"]]).count.should == 1
    Contact.filter([["email", "like", "@madmen.com"]]).count.should == 4
    
    Contact.filter([["paid", "is", true]]).count.should == 2
    Contact.filter([["paid", "is", false]]).count.should == 2
    
    Contact.filter([["number", "greater_than", 80]]).count.should == 1
    Contact.filter([["number", "less_than", 20]]).count.should == 1
    
    Contact.filter([["number", "greater_than", 80]]).count.should == 1
  end
  
  it "operators work for real fields" do
    Contact.filter([["name", "like", "egg"]]).count.should == 1
    Contact.filter([["name", "is", "Don Draper"]]).count.should == 1
    
    Contact.filter([["created_at", "less_than", 3.days.ago]]).count.should == 0
    Contact.filter([["created_at", "greater_than", 3.days.ago]]).count.should == 4
  end
  
  it "order and direction work" do
    Contact.filter([], "name", "asc").first.name.should == "Betty Draper"
    Contact.filter([], "name", "desc").first.name.should == "Peggy Olson"
    
    Contact.filter([], "email", "asc").first.name.should == "Betty Draper"
    Contact.filter([], "email", "desc").first.name.should == "Peggy Olson"
    
    Contact.filter([], "number", "asc").first.name.should == "Joan Hollaway"
    Contact.filter([], "number", "desc").first.name.should == "Betty Draper"
    
    Contact.filter([], "updated_at", "asc").first.name.should == "Don Draper"
    Contact.filter([], "updated_at", "desc").first.name.should == "Peggy Olson"
  end
  
  it "chains work" do
    Contact.filter([
      ["updated_at", "less_than", 3.days.from_now], 
      ["updated_at", "greater_than", 3.days.ago]
    ]).count.should == 4
    
    Contact.filter([
      ["updated_at", "less_than", 3.days.ago],
      ["updated_at", "greater_than", 3.days.from_now]
    ]).count.should == 0
    
    Contact.filter([
      ["birthday", "recurring", false, { start: Time.now.beginning_of_day, finish: Time.now.end_of_day }]
    ]).count.should == 2
  end
  
end