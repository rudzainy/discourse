# frozen_string_literal: true

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/migrations"

module Migrations
  load_rails_environment

  module SchemaGenerator
    def self.run
      puts "Generating intermediate database schema based on Discourse #{Discourse::VERSION::STRING}"
      Migrations::Database::Schema::Generator.new(config_path: "../config/intermediate_db.yml").run
      puts "", "Done"
    end
  end
end

Migrations::SchemaGenerator.run
