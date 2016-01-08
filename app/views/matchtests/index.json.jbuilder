json.array!(@matchtests) do |matchtest|
  json.extract! matchtest, :id
  json.url matchtest_url(matchtest, format: :json)
end
