require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'lib/garuda.rb'

# rake task `create_test_repo` creates the test.git repository for this test

class RunTest < Test::Unit::TestCase
  context "A Garuda instance" do

    setup do
      ENV['repository'] = 'test'
      ENV['ref_type']   = 'heads'
      ENV['ref_name']   = 'master'
      @garuda = Garuda.new
    end

    should "clone and clean up the repository" do
      @garuda.clone_repository
      assert File.directory? @garuda.tree
      @garuda.cleanup
      assert !File.exists?(@garuda.tree)
    end
    
    should 'run the scripts and set environment variables' do
      @garuda.clone_repository.run
      contents = File.read('tests/foo')
      assert_equal "bar\n", contents
      @garuda.cleanup
      File.unlink('tests/foo')
    end
    
  end
end