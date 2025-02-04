# typed: strict
# frozen_string_literal: true

module FeatureMap
  module Private
    class AssignmentApplicator
      extend T::Sig

      sig { params(assignments: T::Array[T::Array[T.nilable(String)]]).void }
      def self.apply_assignments!(assignments)
        file_to_feature_map = map_files_to_feature
        assignments.each do |(filepath, feature)|
          next puts("Missing data: #{filepath}, #{feature}") unless filepath && feature
          next puts("Already assigned: #{filepath}, #{feature}") if file_to_feature_map[filepath]

          apply_assignment(filepath, feature)
        end
      end

      sig { params(filepath: String, feature: String).void }
      def self.apply_assignment(filepath, feature)
        return apply_to_directory(filepath, feature) if File.directory?(filepath)

        # NOTE:  For simplicity we're reading the entire file into system memory
        #        and then writing it back out.  This breaks in theory for exceptionally
        #        large source files on very resource-constrained machines.  In practice it's
        #        probably fine.
        file = File.readlines(filepath)
        case File.extname(filepath)
        when '.cls'
          apply_to_apex(file, filepath, feature)
        when '.html'
          apply_to_html(file, filepath, feature)
        when '.js', '.jsx', '.ts', '.tsx'
          apply_to_javascript(file, filepath, feature)
        when '.rb'
          apply_to_ruby(file, filepath, feature)
        when '.xml'
          apply_to_xml(file, filepath, feature)
        else
          puts "Cannot auto assign #{filepath} to #{feature}"
        end
      end

      sig { params(file: T::Array[String], filepath: String, feature: String).void }
      def self.apply_to_apex(file, filepath, feature)
        File.open(filepath, 'w') do |f|
          f.write("// @feature #{feature}\n\n")
          file.each { |line| f.write(line) }
        end
      end

      sig { params(filepath: String, feature: String).void }
      def self.apply_to_directory(filepath, feature)
        feature_path = File.join(filepath, '.feature')

        File.write(feature_path, "#{feature}\n")
      end

      sig { params(file: T::Array[String], filepath: String, feature: String).void }
      def self.apply_to_html(file, filepath, feature)
        File.open(filepath, 'w') do |f|
          f.write("<!-- @feature #{feature} -->\n\n")
          file.each { |line| f.write(line) }
        end
      end

      sig { params(file: T::Array[String], filepath: String, feature: String).void }
      def self.apply_to_javascript(file, filepath, feature)
        File.open(filepath, 'w') do |f|
          f.write("// @feature #{feature}\n\n")
          file.each { |line| f.write(line) }
        end
      end

      sig { params(file: T::Array[String], filepath: String, feature: String).void }
      def self.apply_to_ruby(file, filepath, feature)
        File.open(filepath, 'w') do |f|
          # NOTE:  No spacing newline; doing so would separate
          #        the feature declaration into the only "first" comment
          #        section, which breaks existing magic comments.
          #        https://docs.ruby-lang.org/en/3.1/syntax/comments_rdoc.html#label-Magic+Comments

          f.write("# @feature #{feature}\n")
          file.each { |line| f.write(line) }
        end
      end

      sig { params(file: T::Array[String], filepath: String, feature: String).void }
      def self.apply_to_xml(file, filepath, feature)
        # NOTE:  Installation of top-level comments in some XML files (notably, in Salesforce)
        #        breaks parsing.  Instead, we'll insert them right after the opening XML declaration.
        xml_declaration = file.index { |line| line =~ /<\?xml/i }
        insert_index = xml_declaration.nil? ? 0 : xml_declaration + 1
        file.insert(insert_index, "<!-- @feature #{feature} -->\n\n")

        File.open(filepath, 'w') do |f|
          file.each { |line| f.write(line) }
        end
      end

      sig { returns(T::Hash[String, String]) }
      def self.map_files_to_feature
        Private.feature_file_assignments.reduce({}) do |content, (feature_name, files)|
          mapped_files = files.to_h { |f| [f, feature_name] }

          content.merge(mapped_files)
        end
      end
    end
  end
end
