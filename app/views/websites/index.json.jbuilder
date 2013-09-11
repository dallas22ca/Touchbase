json.array!(@websites) do |website|
  json.extract! website, :title, :permalink
  json.url website_url(website, format: :json)
end
