# frozen_string_literal: true

RSpec::Matchers.define(:match_response_schema) do |schema|
  match do |response|
    schema_directory = "#{Dir.pwd}/spec/support/schemas"
    schema_path = "#{schema_directory}/#{schema}.json"
    JSON::Validator.validate!(schema_path, response.body)
  end
end

RSpec::Matchers.define(:match_json_schema) do |schema|
  match do |hash_or_json|
    json_string = hash_or_json.is_a?(Hash) ? hash_or_json.to_json : hash_or_json
    schema_directory = "#{Dir.pwd}/spec/support/schemas"
    schema_path = "#{schema_directory}/#{schema}.json"
    JSON::Validator.validate!(schema_path, json_string)
  end
end
