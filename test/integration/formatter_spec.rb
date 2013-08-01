require_relative "../test_helper"

describe Field::Formatter do
  fixtures :all

  it "adds fields to the user" do
    joe = users(:joe)
    path = "#{Rails.root}/test/assets/4withheaders.csv"
    importer = User::Import.from_file path, joe.id
    joe.fields.where(data_type: "string").count.should == 1
    joe.fields.where(data_type: "integer").count.should == 1
  end
end