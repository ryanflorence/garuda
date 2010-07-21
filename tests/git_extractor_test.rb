require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'lib/git_extractor.rb'

class GitExtractorTest < Test::Unit::TestCase
  context "A GitExtractor instance" do
    setup do
      @extractor = GitExtractor.new({
        :path => 'test_repo',
        :branch => 'master',
        :gzip => true
      })
    end

    should "create an archive" do
      @extractor.archive
      assert File.exists? @extractor.tar_path
      @extractor.cleanup
    end
    
    should "extract the files out of an archive" do
      @extractor.extract
      assert File.exists? @extractor.extracted_path
      @extractor.cleanup
    end
    
    should "clean up the files it creates" do
      @extractor.archive
      file = @extractor.tmp_directory_path
      @extractor.cleanup
      assert !File.exists?(file)
    end
  end
end