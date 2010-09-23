require 'rubygems'
require 'test/unit'
require 'shoulda'

# rake task `create_test_repo` creates the test.git repository for this test

class RunTest < Test::Unit::TestCase
  context "The `run` script" do

    should "run the scripts" do
      log = `./run test heads master`
      expected = "# Running script: tests/create_file\nFile created\n"
      assert_equal expected, log
    end

  end
end