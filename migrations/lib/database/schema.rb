# frozen_string_literal: true

module Migrations::Database
  module Schema
    Table = Data.define(:name, :columns, :indexes, :primary_key_column_names)
    Column = Data.define(:name, :datatype, :nullable, :is_primary_key)
    Index = Data.define(:name, :column_names, :unique, :condition)
  end
end
