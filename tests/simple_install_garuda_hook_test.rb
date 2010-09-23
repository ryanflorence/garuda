require 'rubygems'
require 'test/unit'
require 'shoulda'

# rake task `create_test_repo` creates the test.git repository for this test

class SimpleInstallGarudaHookTest < Test::Unit::TestCase
  
  context "The simple install garuda post-receive hook" do
    
    setup do
      @pwd    = Dir.pwd
      @server = @pwd + '/tests/tmp/server'
      @local  = @pwd + '/tests/tmp/local'
    end
    
    should "install the repo hook in test.git and make it executable" do
      Dir.chdir @server
      assert File.exists?('test.git/hooks/post-receive')
      assert File.executable?('test.git/hooks/post-receive')
      Dir.chdir @pwd
    end
    
  end
  
end
