json.array!(@emails) do |email|
  json.extract! email, :user, :criteria, :subject, :plain
  json.url email_url(email, format: :json)
end
