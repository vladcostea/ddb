module Ddb
  ATTR_TYPE_MAP = {
    string: 'S',
    number: 'N',
    map: 'M'
  }.freeze

  KEY_TYPE_MAP = {
    hash: 'HASH',
    range: 'RANGE'
  }.freeze

  DEFAULT_CAPACITY = 1
end

require 'ddb/version'
require 'ddb/exceptions'
require 'ddb/table_definition'
require 'ddb/table_definition_builder'
