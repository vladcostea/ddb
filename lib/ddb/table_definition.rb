module Ddb
  # API
  # params = {
  #   key: {
  #     hash: { project: :string },
  #     range: { timestamp: :number }
  #   },
  #   capacity: {
  #     read: 1,
  #     write: 1
  #   }
  # }
  # td = TableDefinition.new('project', params)
  # td.to_hash -> Aws::DynamoDB::Client complaint table hash
  # 
  # @param [String] table_name
  #   Object that responds to #to_s
  # @param [Hash] definition
  class TableDefinition
    def initialize(table_name, definition)
      @table_name = table_name
      @definition = definition
    end

    def to_hash
      @h ||= {}.merge(table_name)
               .merge(attribute_definitions)
               .merge(key_schema)
               .merge(provisioned_throughput)
               .merge(stream_specification)
    end
    alias_method :value, :to_hash

    def self.build
      raise Exceptions::MissingDefinitionBlock unless block_given?
      builder = TableDefinitionBuilder.new
      yield(builder)
      builder.table_definition
    end

    private

    def table_name
      { 
        table_name: @table_name.to_s 
      }
    end

    def attribute_definitions
      attr_defs = []
      key = @definition[:key]
      key.each_value do |attribute_def|
        name, type = attribute_def.first
        attr_defs << {
          attribute_name: name.to_s,
          attribute_type: ATTR_TYPE_MAP.fetch(type)
        }
      end
      { attribute_definitions: attr_defs }
    end

    def key_schema
      key_schema = []
      key = @definition[:key]
      key.each do |key_type, attribute_def|
        name, = attribute_def.first
        key_schema << {
          attribute_name: name.to_s,
          key_type: KEY_TYPE_MAP.fetch(key_type)
        }
      end
      { 
        key_schema: key_schema 
      }
    end

    def provisioned_throughput
      cap = @definition[:capacity] || {}
      {
        provisioned_throughput: {
          read_capacity_units: (cap[:read] || DEFAULT_CAPACITY).to_i,
          write_capacity_units: (cap[:write] || DEFAULT_CAPACITY).to_i
        }
      }
    end

    def stream_specification
      if @definition[:stream]
        {
          stream_specification: {
            stream_enabled: true,
            stream_view_type: @definition[:stream]
          }
        }
      else
        {
          stream_specification: {
            stream_enabled: false,
            stream_view_type: 'NEW_IMAGE'
          }
        }
      end
    end
  end
end
