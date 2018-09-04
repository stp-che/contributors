require_relative '../rails_helper'

describe Diplom do
  let(:diplom){ described_class.new '2', 'frodo' }

  describe '#filename' do
    it 'is based on name' do
      expect(diplom.filename).to eq 'frodo.pdf'
    end
  end

  describe '#content' do
    it 'returns binary string' do
      expect(diplom.content).to be_kind_of String
      expect(diplom.content.encoding).to be Encoding::BINARY
    end
  end

  describe '.get_archive' do
    let(:archive){
      described_class.get_archive([
        double(:diplom1, filename: 'foo.pdf', content: 'foo pdf content'),
        double(:diplom2, filename: 'bar.pdf', content: 'bar pdf content')
      ])
    }
    let(:archive_tmp_path){ "#{Rails.root}/tmp/#{SecureRandom.hex(10)}.zip" }
    let(:temp_dir){ "#{Rails.root}/tmp/#{SecureRandom.hex(5)}" }

    before {
      File.open(archive_tmp_path, 'wb'){|f| f << archive}
      FileUtils.mkdir temp_dir
      Archive::Zip.extract archive_tmp_path, temp_dir
    }

    after {
      FileUtils.remove_entry_secure archive_tmp_path if File.file?(archive_tmp_path)
      FileUtils.remove_entry_secure temp_dir if File.directory?(temp_dir)
    }

    it 'returns zip archive containing given diploms' do
      expect(Dir.glob("#{temp_dir}/*").size).to eq 2
      expect(File.read "#{temp_dir}/foo.pdf").to eq 'foo pdf content'
      expect(File.read "#{temp_dir}/bar.pdf").to eq 'bar pdf content'
    end
  end
end