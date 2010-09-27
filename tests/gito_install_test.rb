require 'rubygems'
require 'test/unit'
require 'shoulda'

# see rake task `create_install_env`, it installs everything and stuff

class GitoInstallTest < Test::Unit::TestCase
  
  context "The gitolite / gitosis install script" do

    setup do
      @pwd    = Dir.pwd
      @server = @pwd + '/tests/tmp/server'
      @local  = @pwd + '/tests/tmp/local'
    end

    should "clone the garuda repository" do
      Dir.chdir @server
      assert File.directory?('garuda')
      Dir.chdir @pwd
    end
    
    should "install the remote/garuda.git hook" do
      Dir.chdir @server
      assert File.exists? 'garuda.git/hooks/post-receive'
      Dir.chdir @pwd
    end
    
    should "make the remote/garuda.git hook executable" do
      Dir.chdir @server
      assert File.executable? 'garuda.git/hooks/post-receive'
      Dir.chdir @pwd
    end
    
    should "install the hook in remote/test.git" do
      # tests if the remote/garuda hook ran by checking for the presence
      # of post receive hooks on the remote/test.git repository
      Dir.chdir @server
      assert File.exists?('test.git/hooks/post-receive')
      Dir.chdir @pwd
    end
    
    should 'make the hook in remote/test.git executable' do
      Dir.chdir @server
      assert File.executable?('test.git/hooks/post-receive')
      Dir.chdir @pwd
    end
    
    should "run the remote/test.git hook" do
      # tests if the post-recive hook of remote/test.git successfully ran
      # by checking if the script created the 'foo' file.
      assert File.exists?("#{Dir.pwd}/tests/tmp/server/garuda/foo")
    end

  end
  
end
