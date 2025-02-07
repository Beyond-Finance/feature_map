# frozen_string_literal: true

# typed: strict

require 'set'
require 'sorbet-runtime'
require 'json'
require 'yaml'
require 'feature_map/commit'
require 'feature_map/code_features'
require 'feature_map/mapper'
require 'feature_map/validator'
require 'feature_map/private'
require 'feature_map/cli'
require 'feature_map/configuration'

module FeatureMap
  ALL_TEAMS_KEY = 'All Teams'
  NO_FEATURE_KEY = 'No Feature'

  module_function

  extend T::Sig
  extend T::Helpers

  requires_ancestor { Kernel }
  GlobsToAssignedFeatureMap = T.type_alias { T::Hash[String, CodeFeatures::Feature] }

  UpdatedFeaturesByTeam = T.type_alias { T::Hash[String, CommitsByFeature] }
  CommitsByFeature = T.type_alias { T::Hash[String, T::Array[Commit]] }

  sig { params(assignments_file_path: String).void }
  def apply_assignments!(assignments_file_path)
    Private.apply_assignments!(assignments_file_path)
  end

  sig { params(file: String).returns(T.nilable(CodeFeatures::Feature)) }
  def for_file(file)
    @for_file ||= T.let(@for_file, T.nilable(T::Hash[String, T.nilable(CodeFeatures::Feature)]))
    @for_file ||= {}

    return nil if file.start_with?('./')
    return @for_file[file] if @for_file.key?(file)

    Private.load_configuration!

    feature = T.let(nil, T.nilable(CodeFeatures::Feature))

    Mapper.all.each do |mapper|
      feature = mapper.map_file_to_feature(file)
      break if feature # TODO: what if there are multiple features? Should we respond with an error instead of the first match?
    end

    @for_file[file] = feature
  end

  sig { params(feature: T.any(CodeFeatures::Feature, String)).returns(String) }
  def for_feature(feature)
    feature = T.must(CodeFeatures.find(feature)) if feature.is_a?(String)
    feature_report = T.let([], T::Array[String])

    feature_report << "# Report for `#{feature.name}` Feature"

    Private.glob_cache.raw_cache_contents.each do |mapper_description, glob_to_assigned_feature_map|
      feature_report << "## #{mapper_description}"
      file_assignments_for_mapper = []
      glob_to_assigned_feature_map.each do |glob, assigned_feature|
        next if assigned_feature != feature

        file_assignments_for_mapper << "- #{glob}"
      end

      if file_assignments_for_mapper.empty?
        feature_report << 'This feature does not have any files in this category.'
      else
        feature_report += file_assignments_for_mapper.sort
      end

      feature_report << ''
    end

    feature_report.join("\n")
  end

  class InvalidFeatureMapConfigurationError < StandardError
  end

  sig { params(filename: String).void }
  def self.remove_file_annotation!(filename)
    Private::AssignmentMappers::FileAnnotations.new.remove_file_annotation!(filename)
  end

  sig do
    params(
      autocorrect: T::Boolean,
      stage_changes: T::Boolean,
      files: T.nilable(T::Array[String])
    ).void
  end
  def validate!(
    autocorrect: true,
    stage_changes: true,
    files: nil
  )
    Private.load_configuration!

    tracked_file_subset = if files
                            files.select { |f| Private.file_tracked?(f) }
                          else
                            Private.tracked_files
                          end

    Private.validate!(files: tracked_file_subset, autocorrect: autocorrect, stage_changes: stage_changes)
  end

  sig { params(git_ref: T.nilable(String)).void }
  def generate_docs!(git_ref)
    Private.generate_docs!(git_ref)
  end

  sig do
    params(
      unit_path: String,
      integration_path: String,
      regression_path: String,
      regression_assignments_path: String
    ).void
  end
  def generate_test_pyramid!(unit_path, integration_path, regression_path, regression_assignments_path)
    Private.generate_test_pyramid!(unit_path, integration_path, regression_path, regression_assignments_path)
  end

  sig { params(commit_sha: String, code_cov_token: String).void }
  def gather_test_coverage!(commit_sha, code_cov_token)
    Private.gather_test_coverage!(commit_sha, code_cov_token)
  end

  # Given a backtrace from either `Exception#backtrace` or `caller`, find the
  # first line that corresponds to a file with an assigned feature
  sig { params(backtrace: T.nilable(T::Array[String]), excluded_features: T::Array[CodeFeatures::Feature]).returns(T.nilable(CodeFeatures::Feature)) }
  def for_backtrace(backtrace, excluded_features: [])
    first_assigned_file_for_backtrace(backtrace, excluded_features: excluded_features)&.first
  end

  # Given a backtrace from either `Exception#backtrace` or `caller`, find the
  # first assigned file in it, useful for figuring out which file is being blamed.
  sig { params(backtrace: T.nilable(T::Array[String]), excluded_features: T::Array[CodeFeatures::Feature]).returns(T.nilable([CodeFeatures::Feature, String])) }
  def first_assigned_file_for_backtrace(backtrace, excluded_features: [])
    backtrace_with_feature_assignments(backtrace).each do |(feature, file)|
      if feature && !excluded_features.include?(feature)
        return [feature, file]
      end
    end

    nil
  end

  sig { params(backtrace: T.nilable(T::Array[String])).returns(T::Enumerable[[T.nilable(CodeFeatures::Feature), String]]) }
  def backtrace_with_feature_assignments(backtrace)
    return [] unless backtrace

    # The pattern for a backtrace hasn't changed in forever and is considered
    # stable: https://github.com/ruby/ruby/blob/trunk/vm_backtrace.c#L303-L317
    #
    # This pattern matches a line like the following:
    #
    #   ./app/controllers/some_controller.rb:43:in `block (3 levels) in create'
    #
    backtrace_line = %r{\A(#{Pathname.pwd}/|\./)?
        (?<file>.+)       # Matches 'app/controllers/some_controller.rb'
        :
        (?<line>\d+)      # Matches '43'
        :in\s
        `(?<function>.*)' # Matches "`block (3 levels) in create'"
      \z}x

    backtrace.lazy.filter_map do |line|
      match = line.match(backtrace_line)
      next unless match

      file = T.must(match[:file])

      [
        FeatureMap.for_file(file),
        file
      ]
    end
  end
  private_class_method(:backtrace_with_feature_assignments)

  sig { params(klass: T.nilable(T.any(T::Class[T.anything], Module))).returns(T.nilable(CodeFeatures::Feature)) }
  def for_class(klass)
    @memoized_values ||= T.let(@memoized_values, T.nilable(T::Hash[String, T.nilable(CodeFeatures::Feature)]))
    @memoized_values ||= {}
    # We use key because the memoized value could be `nil`
    if @memoized_values.key?(klass.to_s)
      @memoized_values[klass.to_s]
    else
      path = Private.path_from_klass(klass)
      return nil if path.nil?

      value_to_memoize = for_file(path)
      @memoized_values[klass.to_s] = value_to_memoize
      value_to_memoize
    end
  end

  # Groups the provided list of commits (e.g. the changes being deployed in a release) by both the feature they impact
  # and the teams responsible for these features. Returns a hash with keys for each team with features modified within
  # these commits and values that are a hash of features to the set of commits that impact each feature.
  sig { params(commits: T::Array[Commit]).returns(UpdatedFeaturesByTeam) }
  def group_commits(commits)
    commits.each_with_object({}) do |commit, hash|
      commit_features = commit.files.map do |file|
        feature = FeatureMap.for_file(file)
        next nil unless feature

        teams = Private.all_teams_for_feature(feature)
        team_names = teams.empty? ? [ALL_TEAMS_KEY] : teams.map(&:name)

        team_names.sort.each do |team_name|
          hash[team_name] ||= {}
          hash[team_name][feature.name] ||= []
          hash[team_name][feature.name] << commit unless hash[team_name][feature.name].include?(commit)
        end

        feature
      end

      # If the commit did not have any files that relate to a specific feature, include it in a "No Feature" section
      # of the "All Teams" grouping to avoid it being omitted from the resulting grouped commits entirely.
      next unless commit_features.compact.empty?

      hash[ALL_TEAMS_KEY] ||= {}
      hash[ALL_TEAMS_KEY][NO_FEATURE_KEY] ||= []
      hash[ALL_TEAMS_KEY][NO_FEATURE_KEY] << commit
    end
  end

  # Generates a block kit message grouping the provided commits into sections for each feature impacted by the
  # cheanges.
  sig { params(commits_by_feature: CommitsByFeature).returns(T::Array[T::Hash[String, T.untyped]]) }
  def generate_release_notification(commits_by_feature)
    Private.generate_release_notification(commits_by_feature)
  end

  # Generally, you should not ever need to do this, because once your ruby process loads, cached content should not change.
  # Namely, the set of files, and directories which are tracked for feature assignment should not change.
  # The primary reason this is helpful is for clients of FeatureMap who want to test their code, and each test context
  # has different feature assignments and tracked files.
  sig { void }
  def self.bust_caches!
    @for_file = nil
    @memoized_values = nil
    Private.bust_caches!
    Mapper.all.each(&:bust_caches!)
  end

  sig { returns(Configuration) }
  def self.configuration
    Private.configuration
  end
end
