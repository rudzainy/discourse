# frozen_string_literal: true

module Migrations::CLI
  module SchemaCommand
    def self.included(thor)
      thor.class_eval do
        desc "schema [COMMAND]", "Manage database schema"
        subcommand "schema", SchemaSubCommand
      end
    end

    class SchemaSubCommand < Thor
      desc "generate", "Generates the database schema"
      method_option :db, type: :string, default: "development", desc: "Specify the database to use"

      def generate
        db = options[:db]
        puts "Generating schema for #{db} database..."
        # Your logic to generate the schema goes here
      end
    end
  end
end
