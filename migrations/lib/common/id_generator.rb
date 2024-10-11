# frozen_string_literal: true

require "digest/xxhash"

module Migrations
  module IdGenerator
    def self.hash_id(value)
      Digest::XXH3_128bits.base64digest(value)
    end
  end
end
