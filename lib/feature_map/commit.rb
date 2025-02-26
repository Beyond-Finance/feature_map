module FeatureMap
  class Commit
    attr_reader :sha
    attr_reader :description
    attr_reader :pull_request_number
    attr_reader :files

    def initialize(sha: nil, description: nil, pull_request_number: nil, files: [])
      @sha = sha
      @description = description
      @pull_request_number = pull_request_number
      @files = files
    end
  end
end
