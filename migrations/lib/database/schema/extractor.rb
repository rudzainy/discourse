# frozen_string_literal: true

module Migrations::Database::Schema
  class Extractor
    def initialize
      @db = ActiveRecord::Base.connection
    end

    def generate_table(table_config)
      table_name, config = table_config
      config[:virtual] ? virtual_table(table_name, config) : from_database(table_name, config)
    end

    def inspect
      "#<#{self.class}:0x#{object_id}>"
    end

    private

    def from_database(table_name, config)
      primary_key_column_names = @db.primary_keys(table_name)
      columns =
        @db
          .columns(table_name)
          .map do |c|
            Column.new(
              name: c.name,
              datatype: convert_datatype(c.type),
              nullable: c.null,
              is_primary_key: primary_key_column_names.include?(c.name),
            )
          end

      Table.new(table_name, columns, indexes(config), primary_key_column_names)
    end

    def virtual_table(table_name, config)
      primary_key_column_names = Array.wrap(config[:primary_key])
      columns =
        config[:extend].map do |c|
          Column.new(
            name: c[:name],
            datatype: convert_datatype(c[:type]),
            nullable: c.fetch(:is_null, false),
            is_primary_key: primary_key_column_names.include?(c[:name]),
          )
        end

      Table.new(table_name, columns, indexes(config), primary_key_column_names)
    end

    def convert_datatype(type)
      case type
      when :string, :inet
        "TEXT"
      else
        type.to_s.upcase
      end
    end

    def indexes(config)
      config[:indexes]&.map do |index|
        Index.new(
          name: index[:name],
          column_names: Array.wrap(index[:columns]),
          unique: index.fetch(:unique, false),
          condition: index[:condition],
        )
      end
    end
  end
end
