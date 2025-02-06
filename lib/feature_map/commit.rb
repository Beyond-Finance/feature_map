# typed: strict

module FeatureMap
  class Commit
    extend T::Sig

    sig { returns(T.nilable(String)) }
    attr_reader :sha

    sig { returns(T.nilable(String)) }
    attr_reader :description

    sig { returns(T.nilable(String)) }
    attr_reader :pull_request_number

    sig { returns(T::Array[String]) }
    attr_reader :files

    sig do
      params(
        sha: T.nilable(String),
        description: T.nilable(String),
        pull_request_number: T.nilable(String),
        files: T::Array[String]
      ).void
    end
    def initialize(sha: nil, description: nil, pull_request_number: nil, files: [])
      @sha = sha
      @description = description
      @pull_request_number = pull_request_number
      @files = files
    end
  end
end
