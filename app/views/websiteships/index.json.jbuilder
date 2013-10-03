json.array!(@websiteships) do |websiteship|
  json.extract! websiteship, :website_id, :user_id
  json.url websiteship_url(websiteship, format: :json)
end
