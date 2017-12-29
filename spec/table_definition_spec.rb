module Ddb
  RSpec.describe TableDefinition do
    let(:table) { 'table' }
    it 'builds a dynamodb table hash with hash only' do
      definition = {
        key: {
          hash: { project: :string }
        }
      }
      td = described_class.new('table', definition)
      assert_definition(td, {
        attribute_definitions: [
          { attribute_name: 'project', attribute_type: 'S' }
        ],
        key_schema: [
          { attribute_name: 'project', key_type: 'HASH' }
        ],
      })
    end

    it 'builds a dynamodb table hash with hash and range' do
      definition = {
        key: {
          hash: { project: :string },
          range: { timestamp: :number }
        }
      }
      td = described_class.new('table', definition)
      assert_definition(td, {
        attribute_definitions: [
          { attribute_name: 'project', attribute_type: 'S' },
          { attribute_name: 'timestamp', attribute_type: 'N' }
        ],
        key_schema: [
          { attribute_name: 'project', key_type: 'HASH' },
          { attribute_name: 'timestamp', key_type: 'RANGE' }
        ],
      })
    end

    it 'allows custom read and write capacity' do
      definition = {
        key: {
          hash: { project: :string }
        },
        capacity: {
          read: 15,
          write: 10
        }
      }
      td = described_class.new('table', definition)
      assert_definition(td, {
        provisioned_throughput: {
          read_capacity_units: 15,
          write_capacity_units: 10
        }
      })
    end

    it 'allows custom stream stream specification' do
      definition = {
        key: {
          hash: { project: :string }
        },
        stream: 'NEW_AND_OLD_IMAGES'
      }
      td = described_class.new(table, definition)
      assert_definition(td, {
        stream_specification: {
          stream_enabled: true,
          stream_view_type: 'NEW_AND_OLD_IMAGES'
        }
      })
    end

    def assert_definition(td, hash)
      default = {
        table_name: table,
        attribute_definitions: [
          { attribute_name: 'project', attribute_type: 'S' }
        ],
        key_schema: [
          { attribute_name: 'project', key_type: 'HASH' }
        ],
        provisioned_throughput: {
          read_capacity_units: 1,
          write_capacity_units: 1
        },
        stream_specification: {
          stream_enabled: false,
          stream_view_type: 'NEW_IMAGE'
        }
      }
      expected = hash.deep_merge(default)
      expect(td.to_hash).to eq(expected)
    end
  end
end
