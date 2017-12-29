module Ddb
  module Exceptions
    MissingHashKey = Class.new(StandardError)
    MissingTableName = Class.new(StandardError)
    MissingDefinitionBlock = Class.new(StandardError)
  end
end
