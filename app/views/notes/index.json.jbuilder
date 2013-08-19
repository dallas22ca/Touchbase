json.array!(@notes) do |note|
  json.extract! note, :contact_id, :description, :date
  json.url note_url(note, format: :json)
end
