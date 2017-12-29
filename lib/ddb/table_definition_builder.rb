module Ddb
  class TableDefinitionBuilder
    def name(table_name)
      @name = table_name
    end

    def hash_key(name, type)
      @hash_key = { name => type }
    end

    def range_key(name, type)
      @range_key = { name => type }
    end

    def read_capacity(value)
      @read_capacity = value
    end

    def write_capacity(value)
      @write_capacity = value
    end

    def stream(view_type)
      @stream_view_type = view_type
    end

    def table_definition
      raise Exceptions::MissingTableName unless @name
      raise Exceptions::MissingHashKey unless @hash_key
      
      definition = { key: {} }
      definition[:key][:hash] = @hash_key
      definition[:key][:range] = @range_key if @range_key
      if @read_capacity
        definition[:capacity] ||= {}
        definition[:capacity][:read] = @read_capacity
      end
      if @write_capacity
        definition[:capacity] ||= {}
        definition[:capacity][:write] = @write_capacity
      end
      if @stream_view_type
        definition[:stream] = @stream_view_type
      end

      TableDefinition.new(@name, definition)
    end
  end
end
