require 'rubygems'
require 'test/unit'
require 'shoulda'

# rake task `create_test_repo` creates the test.git repository for this test

class PostReceiveHookTest < Test::Unit::TestCase
  
  context "The repository post receive hook" do

    setup do
      @pwd    = Dir.pwd
      @server = @pwd + '/tests/tmp/server'
      @local  = @pwd + '/tests/tmp/local'      
    end

    should "Run the `run` script" do
      
    end

  end
  
end
