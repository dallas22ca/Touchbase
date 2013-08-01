require_relative "../test_helper"

describe Formatter do
  
  it "detects string fields" do
    Formatter.detect("Name", "Dallas Read")[:data_type].should == "string"
    Formatter.detect("Email", "dallasgood@gmail.com")[:data_type].should == "string"
  end
  
  it "detects integer fields" do
    Formatter.detect("Name", 123123)[:data_type].should == "integer"
    Formatter.detect("Email", 234324)[:data_type].should == "integer"
  end
  
  it "detects datetime fields" do
    Formatter.detect("Last Seen", "April 5, 1988 at 12:33pm")[:data_type].should == "datetime"
    Formatter.detect("Signed In", "12/23/11 12:33pm")[:data_type].should == "datetime"
    Formatter.detect("Signed In", "12/23/11 12:33:22pm")[:data_type].should == "datetime"
  end
  
  it "detects recurring_date fields" do
    Formatter.detect("First", "04/05/88")[:data_type].should == "recurring_date"
    Formatter.detect("First", "04/05/1988")[:data_type].should == "recurring_date"
    Formatter.detect("First", "April 5, 1988")[:data_type].should == "recurring_date"
    Formatter.detect("First", "04-05-88")[:data_type].should == "recurring_date"
  end
  
end