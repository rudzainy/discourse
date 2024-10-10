# frozen_string_literal: true

module Migrations::Database::Schema
  class Generator
    def initialize(config_path:, output_stream: $stdout)
      @config_path = File.expand_path(config_path, __dir__)
      config = YAML.load_file(@config_path, symbolize_names: true)

      @core_db_connection = ActiveRecord::Base.connection
      @output_stream = output_stream

      @table_configs = config[:tables]
      @column_configs = config[:columns]
    end

    def run
      if @table_configs.present?
        generate_header
        generate_tables
        # generate_indirectly_ignored_columns_log
        # generate_migration_file
        # validate_migration_file
      end
    end

    def inspect
      "#<#{self.class}:0x#{object_id}>"
    end

    private

    def generate_header
      @output_stream.puts <<~HEADER
        /*
            This file is auto-generated from the Discourse database schema.

            Instead of editing it directly, please update the `migrations/config/intermediate_db.yml` configuration file
            and re-run the `generate_schema` script to update it.
         */
      HEADER
    end

    def generate_tables
      puts "Generating tables..."

      writer = TableWriter.new(@output_stream)
      extractor = Extractor.new

      @table_configs.sort.each do |table_config|
        table = extractor.generate_table(table_config)
        writer.output_table(table)
      end
    end

    def validate_table_names!(table_names)
      existing_table_names = @core_db_connection.tables.to_set

      table_names.each do |table_name|
        if !existing_table_names.include?(table_name)
          raise "Table named '#{table_name}' not found in Discourse database"
        end
      end
    end
  end
end
