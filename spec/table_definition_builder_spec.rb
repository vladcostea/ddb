module Ddb
  RSpec.describe TableDefinitionBuilder do
    class PrefixedTableName
      def initialize(name)
        @name = name
      end

      def to_s
        "prefix_#{@name}"
      end
    end

    it 'builds a dynamodb table hash with hash key only' do
      table_name = PrefixedTableName.new('table')
      builder = described_class.new
      builder.name table_name
      builder.hash_key :project, :string

      definition = builder.table_definition.to_hash
      expect(definition[:table_name]).to eq(table_name.to_s)
      expect(definition[:attribute_definitions]).to eq([
        { attribute_name: 'project', attribute_type: 'S'  }
      ])
      expect(definition[:key_schema]).to eq([
        { attribute_name: 'project', key_type: 'HASH' }
      ])
      expect(definition[:stream_specification][:stream_enabled]).to be_falsey
    end

    it 'builds a dynamodb table hash with hash and range key' do
      table_name = PrefixedTableName.new('table')
      builder = described_class.new
      builder.name table_name
      builder.hash_key :project, :string
      builder.range_key :timestamp, :number

      definition = builder.table_definition.to_hash
      expect(definition[:table_name]).to eq(table_name.to_s)
      expect(definition[:attribute_definitions]).to eq([
        { attribute_name: 'project', attribute_type: 'S'  },
        { attribute_name: 'timestamp', attribute_type: 'N' }
      ])
      expect(definition[:key_schema]).to eq([
        { attribute_name: 'project', key_type: 'HASH' },
        { attribute_name: 'timestamp', key_type: 'RANGE' }
      ])
    end

    it 'sets the default read and write capacity' do
      builder = described_class.new
      builder.name 'table'
      builder.hash_key :project, :string
      definition = builder.table_definition.to_hash
      expect(definition[:provisioned_throughput]).to eq({
        read_capacity_units: 1,
        write_capacity_units: 1
      })
    end

    it 'sets custom read and write capacity values' do
      builder = described_class.new
      builder.name 'table'
      builder.hash_key :project, :string
      builder.read_capacity 10
      builder.write_capacity 15
      definition = builder.table_definition.to_hash

      expect(definition[:provisioned_throughput]).to eq({
        read_capacity_units: 10,
        write_capacity_units: 15
      })
    end

    it 'sets custom stream view type' do
      builder = described_class.new
      builder.name 'table'
      builder.hash_key :project, :string
      builder.stream 'NEW_AND_OLD_IMAGES'
      definition = builder.table_definition.to_hash
      expect(definition[:stream_specification]).to eq({
        stream_enabled: true,
        stream_view_type: 'NEW_AND_OLD_IMAGES'
      })
    end

    it 'raises error if no table name set' do
      builder = described_class.new
      expect {
        builder.table_definition
      }.to raise_error(Exceptions::MissingTableName)
    end

    it 'raises error if no hash_key set' do
      builder = described_class.new
      builder.name 'table'
      expect {
        builder.table_definition
      }.to raise_error(Exceptions::MissingHashKey)
    end
  end
end
