require 'rubygems'
require 'test/unit'
require 'shoulda'

# rake task `create_test_repo` creates the test.git repository for this test

class PostReceiveHookTest < Test::Unit::TestCase
  
  context "The repository post receive hook" do

    should "Run the `run` script" do
      # tests if the post-recive hook of remote/test.git successfully ran
      # by checking if the script created the 'foo' file.
      assert File.exists?("#{Dir.pwd}/tests/tmp/server/garuda/foo")
    end

  end
  
end
