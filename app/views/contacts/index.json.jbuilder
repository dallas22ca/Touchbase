json.array!(@contacts) do |contact|
  json.extract! contact, :user_id, :name, :email, :details
  json.url contact_url(contact, format: :json)
end
