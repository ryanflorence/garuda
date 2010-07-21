require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'highline/import'
require 'lib/multi_ftp.rb'

class MultiFTPTest < Test::Unit::TestCase
  context "An MultiFtp instance" do
    setup do
      @ftp = MultiFTP.new('linux')
    end

    should 'upload the files' do
      `rm -rf test_repo/.git`
      
      puts ":: I need some help, please give me some ftp information ..."
      host = ask("FTP Hostname (localhost): ") { |q| q.echo = true }
      user = ask("FTP User (test): ") { |q| q.echo = true }
      pass = ask("FTP User Password: ") { |q| q.echo = '*' }
      @ftp.setup(host, user, pass)
      
      dir = "unit-test-#{Time.now.strftime "%Y-%m-%d-%H%M%S"}"
      pwd = `pwd`.chomp
      @ftp.go_send("#{pwd}/test_repo", dir)
      @ftp.go_get("#{pwd}/test_get", dir)

      Dir.chdir('..') # Not sure what's moving us into here
      repo_ls = `ls test_repo`
      retrieved_ls = `ls test_get`
      assert_equal repo_ls, retrieved_ls
      
      # cleanup
      @ftp.delete_directory(dir)
      `rm -rf test_get`
    end
    
  end
end