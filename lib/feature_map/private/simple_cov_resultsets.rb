class SimpleCovResultsets
  def self.fetch_coverage_stats(simplecov_resultsets)
    root_dir = "#{Dir.pwd}/"

    simplecov_resultsets.reduce({}) do |combined_stats, simplecov_resultset|
      coverage_data = simplecov_resultset['RSpec']['coverage']

      file_stats = coverage_data.map do |absolute_path, file_data|
        relative_path = absolute_path.sub(root_dir, '')
        lines_data = file_data['lines']

        executable_lines = lines_data.compact.size
        covered_lines = lines_data.count { |line| line&.positive? }
        missed_lines = executable_lines - covered_lines
        coverage_percentage = executable_lines.positive? ? ((covered_lines.to_f / executable_lines) * 100).round(2) : 0

        # Return a tuple of [path, stats]
        [relative_path, {
          'lines' => executable_lines,
          'hits' => covered_lines,
          'misses' => missed_lines,
          'coverage_ratio' => coverage_percentage
        }]
      end

      combined_stats.merge(file_stats.to_h)
    end
  end
end
