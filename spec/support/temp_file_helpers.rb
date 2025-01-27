# typed: false
# frozen_string_literal: true

require 'tempfile'

module FeatureMap
  module TempFileHelpers
    def with_temp_file(content:)
      file = Tempfile.new(['test', '.rb'])

      file.write(content)
      file.flush
      file.rewind

      File.read(file.path)

      yield(file.path)
    ensure
      file.close
      file.unlink
    end
  end
end
