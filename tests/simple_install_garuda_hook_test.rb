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
      Dir.chdir @server
      load "../../../.install/simple.rb"
      Dir.chdir @pwd
    end
    
    should "install the repo hook in test.git and make it executable" do
      Dir.chdir @local
      puts "# Garuda test script: Cloning the 'server' Garuda to the 'local' Garuda."
      `git clone ../server/garuda`
      Dir.chdir 'garuda'
      puts "# Garuda test script: Committing dummy file and pushing to initiate the hook on the 'server'"
      `touch foo; git add .; git commit -m 'nothing'; git push origin master`
      Dir.chdir @server
      assert File.exists?('test.git/hooks/post-receive')
      assert File.executable?('test.git/hooks/post-receive')
      Dir.chdir @pwd
    end
    
  end
  
end
