json.array!(@relations) do |relation|
  json.extract! relation, :id
  json.url relation_url(relation, format: :json)
end
