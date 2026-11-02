# @feature Core Library
# frozen_string_literal: true

module FeatureMap
  module Private
    class PullRequestAnnotator
      METRICS_FILE_PATH = '.feature_map/metrics.yml'
      COMMENT_MARKER = '<!-- FEATURE_ANALYSIS_COMMENT -->'
      FEATURE_LABEL_COLOR = '0366d6'
      FEATURE_METRIC_LABELS = {
        'abc_size' => 'ABC Size',
        'lines_of_code' => 'Lines of Code',
        'cyclomatic_complexity' => 'Cyclomatic Complexity'
      }.freeze

      def initialize(client, full_repo_name, pr_number, base_branch_metrics_path, doc_site_base_url)
        @client = client
        @full_repo_name = full_repo_name
        @pr_number = pr_number
        @doc_site_base_url = doc_site_base_url
        @base_branch_metrics_path = base_branch_metrics_path
      end

      def announce
        changed_files = lookup_changed_files
        affected_features = identify_affected_features(changed_files)
        feature_metrics = gather_feature_metrics(affected_features)
        update_or_create_comment(affected_features, feature_metrics)
        update_labels(affected_features.keys)
      end

      private

      def lookup_changed_files
        files = @client.pull_request_files(@full_repo_name, @pr_number)
        changed_files = files.map(&:filename)

        puts "\nFinal changed files: #{changed_files.inspect}"
        changed_files
      rescue StandardError => e
        puts "Error fetching PR files: #{e.message}"
        []
      end

      def identify_affected_features(changed_files)
        affected = {}

        changed_files.each do |file|
          feature = FeatureMap.for_file(file)
          next unless feature

          affected[feature] ||= []
          affected[feature] << file
        end

        puts "All Affected Features: #{affected.keys}"

        affected
      end

      def gather_feature_metrics(affected_features)
        base_branch_metrics = load_base_branch_feature_metrics
        pr_branch_metrics = load_pr_branch_feature_metrics

        metrics = {}

        affected_features.each_key do |feature|
          next if !pr_branch_metrics[feature.name] || !base_branch_metrics[feature.name]

          feature_metrics = {}
          FEATURE_METRIC_LABELS.each_key do |metric|
            pr_branch_value = pr_branch_metrics[feature.name][metric] || 0
            base_branch_value = base_branch_metrics[feature.name][metric] || 0
            feature_metrics[metric] = { 'base_branch' => base_branch_value, 'pr_branch' => pr_branch_value }
          end
          metrics[feature.name] = feature_metrics
        end

        puts "\nMetrics for Affected Features: #{metrics}"

        metrics
      end

      def load_base_branch_feature_metrics
        YAML.load_file(@base_branch_metrics_path)['features']
      rescue StandardError => e
        puts "Error loading #{@base_branch_metrics_path}: #{e.class} - #{e.message}"
        {}
      end

      def load_pr_branch_feature_metrics
        YAML.load_file(METRICS_FILE_PATH)['features']
      rescue StandardError => e
        puts "Error loading #{METRICS_FILE_PATH}: #{e.class} - #{e.message}"
        {}
      end

      def build_feature_message(affected_features, feature_metrics)
        message = []
        message << COMMENT_MARKER

        return nil if affected_features.empty?

        message << "## 📢 Features Affected by this PR\n"
        message.concat(build_feature_sections(affected_features, feature_metrics))

        message.join("\n")
      end

      def build_feature_sections(affected_features, feature_metrics)
        sections = []
        affected_features
          .sort_by { |feature, _files| feature.name }
          .each_with_index do |(feature, files), index|
            sections << build_feature_section(
              feature.name,
              files,
              feature_metrics,
              is_last: index == affected_features.length - 1
            )
          end
        sections
      end

      def build_feature_section(feature_name, files, feature_metrics, is_last: false)
        section = []
        puts "\nBuilding section for feature: '#{feature_name}'"
        definition = FeatureMap::CodeFeatures.find(feature_name)
        puts "Found definition: #{definition.inspect}"

        docs_url = "#{@doc_site_base_url}#{URI::DEFAULT_PARSER.escape(feature_name)}"

        section << "\n"
        section << "#{feature_name} - [View Documentation →](#{docs_url})\n"

        section << '<details>'
        section << "<summary>#{files.length} file(s) changed</summary>\n"
        section << "\n<br>\n"

        section << "**Description:** #{definition.raw_hash['description']}\n" if definition&.raw_hash&.dig('description')

        section << '**Changed Files:**'
        files.sort.each do |file|
          section << "- `#{file}`"
        end

        section << "\n<br>\n"

        section.concat(build_feature_metrics_table(feature_name, feature_metrics))

        section << "\n</details>\n"
        section << "\n<hr>\n" unless is_last
        section.join("\n")
      end

      def build_feature_metrics_table(feature_name, feature_metrics)
        return ['*No metrics found for this feature.*'] unless feature_metrics[feature_name]

        table = []
        table << '| Metric | Initial Value | Change in Value (pct) | Final Value |'
        table << '|---|:---:|:---:|:---:|'

        feature_metrics[feature_name].each do |metric_name, values|
          metric_label = FEATURE_METRIC_LABELS[metric_name] || metric_name.gsub('_', ' ').capitalize
          initial_value = values['base_branch'] || 0
          ending_value = values['pr_branch'] || 0
          absolute_change = (ending_value - initial_value).round(2)
          percentage_change = (absolute_change.to_f / initial_value * 100).round(2)

          table << "| #{metric_label} | #{initial_value} | #{absolute_change} (#{percentage_change}%) | #{ending_value} |"
        end

        table
      end

      def find_existing_comment
        comments = @client.issue_comments(@full_repo_name, @pr_number)
        comments.find { |comment| comment.body.start_with?(COMMENT_MARKER) }
      end

      def update_or_create_comment(affected_features, feature_metrics)
        message = build_feature_message(affected_features, feature_metrics)

        existing_comment = find_existing_comment
        if existing_comment
          if message
            update_comment(existing_comment, message)
            puts 'Comment updated'
          else
            delete_comment(existing_comment)
            puts 'No features found; Comment removed'
          end
        elsif message
          add_comment(message)
          puts 'Comment created'
        else
          puts 'No features found; Comment skipped'
        end
      end

      def update_labels(features)
        current_labels = lookup_current_labels
        feature_labels = current_labels.select do |label|
          label.start_with?(FeatureMap::CodeFeatures::Feature::LABEL_PREFIX)
        end
        affected_feature_labels = features.map(&:label)

        puts "\nLabel Management:"
        puts "  Current feature labels: #{feature_labels.inspect}"
        puts "  Features to be labeled: #{features.map(&:name).inspect}"

        remove_feature_labels(feature_labels, affected_feature_labels)

        add_feature_labels(feature_labels, affected_feature_labels)
      end

      def remove_feature_labels(feature_labels, affected_feature_labels)
        feature_labels
          .reject { |existing_label| affected_feature_labels.include?(existing_label) }
          .each do |existing_label|
            puts "  Removing: '#{existing_label}' (feature '#{existing_label}' no longer changed)"
            remove_label(existing_label)
          end
      end

      def add_feature_labels(feature_labels, affected_feature_labels)
        affected_feature_labels.each do |label_name|
          if feature_labels.include?(label_name)
            puts "  Keeping: '#{label_name}'"
          else
            puts "  Adding: '#{label_name}'"
            ensure_label_exists(label_name)
            add_label(label_name)
          end
        end
      end

      def lookup_current_labels
        issue = @client.issue(@full_repo_name, @pr_number)
        issue.labels.map(&:name)
      rescue StandardError => e
        puts "Error fetching current labels: #{e.class} - #{e.message}"
        []
      end

      def ensure_label_exists(label_name)
        @client.label(@full_repo_name, label_name)
      rescue Octokit::NotFound
        create_label(label_name)
      end

      def add_comment(message)
        @client.add_comment(@full_repo_name, @pr_number, message)
      rescue StandardError => e
        puts "Error adding comment: #{e.class} - #{e.message}"
      end

      def update_comment(existing_comment, message)
        @client.update_comment(@full_repo_name, existing_comment.id, message)
      rescue StandardError => e
        puts "Error updating comment: #{e.class} - #{e.message}"
      end

      def delete_comment(existing_comment)
        @client.delete_comment(@full_repo_name, existing_comment.id)
      rescue StandardError => e
        puts "Error deleting comment: #{e.class} - #{e.message}"
      end

      def create_label(label_name)
        @client.add_label(@full_repo_name, label_name, FEATURE_LABEL_COLOR)
      rescue StandardError => e
        puts "Error creating label: #{e.class} - #{e.message}"
      end

      def add_label(label_name)
        @client.add_labels_to_an_issue(@full_repo_name, @pr_number, [label_name])
      rescue StandardError => e
        puts "Error adding label: #{e.class} - #{e.message}"
      end

      def remove_label(label_name)
        @client.remove_label(@full_repo_name, @pr_number, label_name)
      rescue StandardError => e
        puts "Error removing label: #{e.class} - #{e.message}"
      end
    end
  end
end
