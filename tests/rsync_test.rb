require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'lib/rsync.rb'

class RsyncTest < Test::Unit::TestCase
  context "An Rsync instance" do
    setup do
      @rsync = Rsync.new
    end

    should 'synchronize the folders' do
      `rm -rf test_repo/.git`
      @rsync.run({
        'dst' => 'test_destination',
        'src' => 'test_repo/',
        'options' => '-glpPrtvzq'
      })
      src_ls = `ls test_repo`
      dst_ls = `ls test_destination`
      assert_equal src_ls, dst_ls
    end
    
  end
end