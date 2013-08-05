require_relative "../test_helper"

describe User do
  fixtures :all
  
  it "can sign up when visiting the root path" do
    visit root_url
    page.should have_content "Email"
  end
  
  it "is asked to upload contacts if none exists" do
    joe = users(:joe)
    login_as joe
    joe.contacts.count.should == 0
    visit contacts_path
    page.should have_content "upload"
  end
  
  it "sees his contacts if he has some" do
    joe = users(:joe)
    joe.fields.create! title: "Email", permalink: "email", data_type: "string"
    login_as joe
    path = "#{Rails.root}/test/assets/4withheaders.csv"
    importer = Importer.new(joe.id, "file", false, path).import
    visit contacts_path
    page.should have_content @name
  end
end