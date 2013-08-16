require_relative "../test_helper"

describe User do
  fixtures :all
  
  before :each do
    Contact.destroy_all
  end
  
  it "can sign up when visiting the root path" do
    joe = users(:joe)
    logout joe
    visit root_path
    page.should have_content "Email"
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