require 'rubygems'
require 'test/unit'
require 'shoulda'

# see rake task `create_install_env`, it installs everything and stuff

class SimpleInstallTest < Test::Unit::TestCase
  
  context "The simple install script" do

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
    
    should "install the post-receive script and make it executable" do
      Dir.chdir @server
      assert File.exists? 'garuda/.git/hooks/post-receive'
      assert File.executable? 'garuda/.git/hooks/post-receive'
      Dir.chdir @pwd
    end

  end
  
end
