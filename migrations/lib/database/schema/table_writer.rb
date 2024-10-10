# frozen_string_literal: true

module Migrations::Database::Schema
  class TableWriter
    def initialize(output_stream)
      @output = output_stream
    end

    def output_table(table)
      @output.puts "CREATE TABLE #{table.name}"
      @output.puts "("
      @output.puts format_columns(table)
      @output.puts ");"
      output_indexes(table)
      @output.puts ""
    end

    private

    def format_columns(table)
      columns = table.columns
      has_composite_primary_key = table.primary_key_column_names.size > 1

      column_definitions = create_column_definitions(columns, has_composite_primary_key)

      if has_composite_primary_key
        pk_definition = table.primary_key_column_names.join(", ")
        column_definitions << "    PRIMARY KEY (#{pk_definition})"
      end

      column_definitions.join(",\n")
    end

    def create_column_definitions(columns, has_composite_primary_key)
      max_column_name_length = columns.map { |c| c.name.length }.max
      max_datatype_length = columns.map { |c| c.datatype.length }.max

      columns
        .sort_by { |c| [c.is_primary_key ? 0 : 1, c.name] }
        .map do |c|
          definition = [c.name.ljust(max_column_name_length), c.datatype.ljust(max_datatype_length)]

          definition << "NOT NULL" unless c.nullable
          definition << "PRIMARY KEY" if c.is_primary_key && !has_composite_primary_key

          definition = definition.join(" ")
          definition.strip!

          "    #{definition}"
        end
    end

    def output_indexes(table)
      return if !table.indexes

      table.indexes.each do |index|
        @output.puts ""
        @output.print "CREATE "
        @output.print "UNIQUE " if index.unique
        @output.print "INDEX #{index.name} ON #{table.name} (#{index.column_names.join(", ")})"
        @output.print " #{index.condition}" if index.condition.present?
        @output.puts ";"
      end
    end
  end
end
