# typed: strict
# frozen_string_literal: true

module FeatureMap
  module Private
    #
    # TODO: Document this class
    #
    class AdditionalMetricsFile
      extend T::Sig

      class FileContentError < StandardError; end

      FEATURES_KEY = 'features'

      FeatureName = T.type_alias { String }

      FeatureMetrics = T.type_alias do
        T::Hash[
          String,
          T.any(Integer, Float, T::Hash[String, String])
        ]
      end

      FeaturesContent = T.type_alias do
        T::Hash[
          FeatureName,
          FeatureMetrics
        ]
      end

      sig { params(metrics: T::Hash[String, T.untyped], test_coverage: T::Hash[String, T.untyped], health_config: T::Hash[String, T.untyped]).void }
      def self.write!(metrics, test_coverage, health_config)
        FileUtils.mkdir_p(path.dirname) if !path.dirname.exist?

        path.write([header_comment, "\n", generate_content(metrics, test_coverage, health_config).to_yaml].join)
      end

      sig { returns(Pathname) }
      def self.path
        Pathname.pwd.join('.feature_map/additional-metrics.yml')
      end

      sig { returns(String) }
      def self.header_comment
        <<~HEADER
          # STOP! - DO NOT EDIT THIS FILE MANUALLY
          # This file was automatically generated by "bin/featuremap validate". The next time this file
          # is generated any changes will be lost. For more details:
          # https://github.com/Beyond-Finance/feature_map
          #
          # It is NOT recommended to commit this file into your source control. It will change as a
          # result of nearly all other source code changes. This file should be ignored by your source
          # control but can be used for other feature analysis operations (e.g. documentation
          # generation, etc).
        HEADER
      end

      sig { params(feature_metrics: T::Hash[String, T.untyped], feature_test_coverage: T::Hash[String, T.untyped], health_config: T::Hash[String, T.untyped]).returns(T::Hash[String, FeaturesContent]) }
      def self.generate_content(feature_metrics, feature_test_coverage, health_config)
        feature_additional_metrics = T.let({}, FeaturesContent)

        cyclomatic_complexity_ratios = feature_metrics.map { |_k, m| m[FeatureMetricsCalculator::COMPLEXITY_RATIO_METRIC] }.compact
        encapsulation_ratios = feature_metrics.map { |_k, m| m[FeatureMetricsCalculator::ENCAPSULATION_RATIO_METRIC] }.compact
        feature_sizes = feature_metrics.map { |_k, m| m[FeatureMetricsCalculator::LINES_OF_CODE_METRIC] }.compact
        test_coverage_ratios = feature_test_coverage.map { |_k, c| c[TestCoverageFile::COVERAGE_RATIO] }.compact

        Private.feature_file_assignments.each_key do |feature_name|
          cyclomatic_complexity = calculate(cyclomatic_complexity_ratios, feature_metrics.dig(feature_name, FeatureMetricsCalculator::COMPLEXITY_RATIO_METRIC) || 0)
          encapsulation = calculate(encapsulation_ratios, feature_metrics.dig(feature_name, FeatureMetricsCalculator::ENCAPSULATION_RATIO_METRIC) || 0)
          feature_size = calculate(feature_sizes, feature_metrics.dig(feature_name, FeatureMetricsCalculator::LINES_OF_CODE_METRIC) || 0)
          test_coverage = calculate(test_coverage_ratios, feature_test_coverage.dig(feature_name, TestCoverageFile::COVERAGE_RATIO) || 0)
          health = health_score_for(cyclomatic_complexity, encapsulation, test_coverage, health_config)

          feature_additional_metrics[feature_name] = {
            'cyclomatic_complexity' => cyclomatic_complexity,
            'encapsulation' => encapsulation,
            'feature_size' => feature_size,
            'test_coverage' => test_coverage,
            'health' => health
          }
        end

        { FEATURES_KEY => feature_additional_metrics }
      end

      sig { returns(FeaturesContent) }
      def self.load_features!
        metrics_content = YAML.load_file(path)

        return metrics_content[FEATURES_KEY] if metrics_content.is_a?(Hash) && metrics_content[FEATURES_KEY]

        raise FileContentError, "Unexpected content found in #{path}. Use `bin/featuremap validate` to regenerate it and try again."
      rescue Psych::SyntaxError => e
        raise FileContentError, "Invalid YAML content found at #{path}. Error: #{e.message} Use `bin/featuremap validate` to generate it and try again."
      rescue Errno::ENOENT
        raise FileContentError, "No feature metrics file found at #{path}. Use `bin/featuremap validate` to generate it and try again."
      end

      sig { params(collection: T::Array[T.any(Integer, Float)], score: T.any(Integer, Float)).returns({ 'percentile' => Float, 'percent_of_max' => Integer, 'score' => T.any(Integer, Float) }) }
      def self.calculate(collection, score)
        max = collection.max || 0
        percentile = percentile_of(collection, score)
        percent_of_max = max.zero? ? 0 : ((score.to_f / max) * 100).round.to_i

        { 'percentile' => percentile, 'percent_of_max' => percent_of_max, 'score' => score }
      end

      sig { params(arr: T::Array[T.any(Integer, Float)], val: T.any(Integer, Float)).returns(Float) }
      def self.percentile_of(arr, val)
        return 0.0 if arr.empty?

        ensure_array_of_floats = arr.map(&:to_f)
        ensure_float_value = val.to_f

        below_or_equal_count = ensure_array_of_floats.reduce(0) do |acc, v|
          if v < ensure_float_value
            acc + 1
          elsif v == ensure_float_value
            acc + 0.5
          else
            acc
          end
        end

        ((100 * below_or_equal_count) / ensure_array_of_floats.length).to_f
      end

      sig { params(awardable_points: Integer, score: T.any(Float, Integer), score_threshold: Integer, percent_of_max: T.nilable(T.any(Integer, Float)), percent_of_max_threshold: T.nilable(T.any(Integer, Float))).returns({ 'awardable_points' => Integer, 'health_score' => T.any(Float, Integer), 'close_to_maximum_score' => T::Boolean, 'exceeds_score_threshold' => T::Boolean }) }
      def self.health_score_component(awardable_points, score, score_threshold, percent_of_max = 0, percent_of_max_threshold = 100)
        close_to_maximum_score = T.must(percent_of_max) >= T.must(percent_of_max_threshold)
        exceeds_score_threshold = score >= score_threshold

        if close_to_maximum_score || exceeds_score_threshold
          { 'awardable_points' => awardable_points, 'health_score' => awardable_points, 'close_to_maximum_score' => close_to_maximum_score, 'exceeds_score_threshold' => exceeds_score_threshold }
        else
          { 'awardable_points' => awardable_points, 'health_score' => (score.to_f / score_threshold) * awardable_points, 'close_to_maximum_score' => close_to_maximum_score, 'exceeds_score_threshold' => exceeds_score_threshold }
        end
      end

      sig {
        params(
          encapsulation: T::Hash[String, T.any(Integer, Float)],
          cyclomatic_complexity: T::Hash[String, T.any(Integer, Float)],
          test_coverage: T::Hash[String, T.any(Integer, Float)],
          health_config: T::Hash[String, T.untyped]
        ).returns(T::Hash[String, T.untyped])
      }
      def self.health_score_for(encapsulation, cyclomatic_complexity, test_coverage, health_config)
        cyclomatic_complexity_config = health_config['components']['cyclomatic_complexity']
        encapsulation_config = health_config['components']['encapsulation']
        test_coverage_config = health_config['components']['test_coverage']

        test_coverage_component = health_score_component(test_coverage_config['weight'], T.must(test_coverage['score']), test_coverage_config['score_threshold'])
        cyclomatic_complexity_component = health_score_component(cyclomatic_complexity_config['weight'], T.must(cyclomatic_complexity['percentile']), cyclomatic_complexity_config['score_threshold'], cyclomatic_complexity['percent_of_max'], 100 - cyclomatic_complexity_config['minimum_variance'])
        encapsulation_component = health_score_component(encapsulation_config['weight'], T.must(encapsulation['percentile']), encapsulation_config['score_threshold'], encapsulation['percent_of_max'], 100 - encapsulation_config['minimum_variance'])

        overall = test_coverage_component['health_score'] + cyclomatic_complexity_component['health_score'] + encapsulation_component['health_score']

        { 'test_coverage_component' => test_coverage_component, 'cyclomatic_complexity_component' => cyclomatic_complexity_component, 'encapsulation_component' => encapsulation_component, 'overall' => overall }
      end
    end
  end
end
