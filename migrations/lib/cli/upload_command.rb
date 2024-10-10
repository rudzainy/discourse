# frozen_string_literal: true

module Migrations::CLI
  module UploadCommand
    def self.included(thor)
      thor.class_eval do
        desc "upload", "Upload a file"
        def upload
          puts "Uploading..."
        end
      end
    end
  end
end
