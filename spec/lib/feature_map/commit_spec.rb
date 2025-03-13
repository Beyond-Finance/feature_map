# @feature Core Library
RSpec.describe FeatureMap::Commit do
  describe '.new' do
    it 'persists all attributes' do
      commit = described_class.new(sha: '123abc', description: 'Test commit message.', pull_request_number: '1000', files: ['app/my_file.rb', 'app/my_error.rb'])
      expect(commit.sha).to eq('123abc')
      expect(commit.description).to eq('Test commit message.')
      expect(commit.pull_request_number).to eq('1000')
      expect(commit.files).to eq(['app/my_file.rb', 'app/my_error.rb'])
    end

    it 'assigns a default value for each attribute' do
      commit = described_class.new
      expect(commit.sha).to be_nil
      expect(commit.description).to be_nil
      expect(commit.pull_request_number).to be_nil
      expect(commit.files).to eq([])
    end
  end
end
