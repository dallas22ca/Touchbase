require_relative "../test_helper"

describe Formatter do
  
  it "detects string fields" do
    Formatter.detect("Name", "Dallas Read")[:data_type].should == "string"
    Formatter.detect("Email", "dallasgood@gmail.com")[:data_type].should == "string"
    Formatter.detect("Address", "2846 Andorra Circle")[:data_type].should == "string"
    Formatter.detect("Address Line 2", "Suite 34534")[:data_type].should == "string"
    Formatter.detect("Mailing Address", "3432 Yonge Street, Suite #3333")[:data_type].should == "string"
    Formatter.detect("Mailing Address", "3432 Yonge Street Suite 333")[:data_type].should == "string"
  end
  
  it "detects integer fields" do
    Formatter.detect("Count", 123123)[:data_type].should == "integer"
    Formatter.detect("Number", "234324")[:data_type].should == "integer"
    Formatter.detect("How Many?", "-34")[:data_type].should == "integer"
  end
  
  it "detects datetime fields" do
    Formatter.detect("Last Seen", "April 5, 1988 at 12:33pm")[:data_type].should == "datetime"
    Formatter.detect("Signed In", "12/23/11 12:33pm")[:data_type].should == "datetime"
    Formatter.detect("Signed In", "12/23/11 12:33:22pm")[:data_type].should == "datetime"
    Formatter.detect("First", "04/05/88")[:data_type].should == "datetime"
    Formatter.detect("Birthday", "04/05/1988")[:data_type].should == "datetime"
    Formatter.detect("Anniversary", "April 5, 1988")[:data_type].should == "datetime"
    Formatter.detect("Date", "04-05-88")[:data_type].should == "datetime"
  end
  
end