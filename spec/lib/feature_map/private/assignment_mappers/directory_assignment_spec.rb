module FeatureMap
  RSpec.describe Private::AssignmentMappers::DirectoryAssignment do
    describe 'FeatureMap.for_file' do
      before do
        write_configuration

        write_file('a/b/.feature', <<~CONTENTS)
          Bar
        CONTENTS
        write_file('a/b/c/c_file.jsx')
        write_file('a/b/b_file.jsx')
        write_file('a/b/[test]/b_file.jsx')
        write_file('features/definitions/bar.yml', <<~CONTENTS)
          name: Bar
        CONTENTS
      end

      subject { described_class.new }

      before do
        subject.bust_caches!
      end

      it 'can find the owner of files in team-owned directory' do
        expect(subject.map_file_to_feature('a/b/b_file.jsx').name).to eq 'Bar'
      end

      it 'can find the owner of files containing [] dirs' do
        expect(subject.map_file_to_feature('a/b/[test]/b_file.jsx').name).to eq 'Bar'
      end

      it 'can find the owner of files in a sub-directory of a team-owned directory' do
        expect(subject.map_file_to_feature('a/b/c/c_file.jsx').name).to eq 'Bar'
      end

      it 'returns null when no team is found' do
        expect(subject.map_file_to_feature('tmp/tmp/foo.txt')).to be_nil
        expect(subject.map_file_to_feature('../tmp/tmp/foo.txt')).to be_nil
        expect(subject.map_file_to_feature(Pathname.pwd.join('tmp/tmp/foo.txt').to_s)).to be_nil
      end

      it 'looks for feature assignment file within directory' do
        expect(subject.map_file_to_feature('a/b').name).to eq 'Bar'
        expect(subject.map_file_to_feature('a/../a/b').name).to eq 'Bar'
        expect(subject.map_file_to_feature(Pathname.pwd.join('a/b').to_s).name).to eq 'Bar'
      end
    end
  end
end
