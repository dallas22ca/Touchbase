json.array!(@contacts) do |contact|
  json.extract! contact, :name, :data
  json.url contact_url(contact, format: :json)
end
