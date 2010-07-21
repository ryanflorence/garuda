require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'lib/git_data.rb'

class GitDataTest < Test::Unit::TestCase
  context "An GitData instance" do
    setup do
      @data = GitData.new('/Users/rpflo/OpenSource/SlideShow')
    end

    should 'get the tags' do
      
      assert_equal 1, 1
    end
    
  end
end