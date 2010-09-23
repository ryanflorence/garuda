require 'rubygems'
require 'test/unit'
require 'shoulda'

class LanguageTest < Test::Unit::TestCase
  context "Your machine" do

    setup do
      ENV['arg1'] = 'one'
      ENV['arg2'] = 'two'
    end

    should "run ruby scripts" do
      log = `./bin/tests/ruby-test`
      expected = "one\ntwo\n"
      assert_equal expected, log
    end
    
    should "run python scripts" do
      log = `./bin/tests/python-test`
      expected = "one\ntwo\n"
      assert_equal expected, log
    end
    
    should "run node scripts" do
      log = `./bin/tests/node-test`
      expected = "one\ntwo\n"
      assert_equal expected, log
    end

  end
end