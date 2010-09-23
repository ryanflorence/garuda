require 'rubygems'
require 'yaml'
require 'fileutils'
require 'lib/runner.rb'

class Garuda
  
  def initialize
    # set variables
    repository = ENV['repository'] = ARGV[0]
    ref_type   = ENV['ref_type']   = ARGV[1]
    ref_name   = ENV['ref_name']   = ARGV[2]
    
    # load the application config
    app_config = YAML::load(File.open('config.yml'))

    # load the repository config
    config = YAML::load(File.open("#{app_config['config']}/#{repository}.yml"))

    # clone the repository
    tmp_dir = 'tmp/' + Time.now.strftime("%Y%m%d%H%M%S")
    Dir.mkdir(tmp_dir);
    Dir.chdir(tmp_dir);
    `git clone ../../#{app_config['repos']}/#{repository}.git`
    Dir.chdir(repository)
    tree = ENV['tree'] = Dir.pwd
    Dir.chdir('../../../');

    # run the scripts
    Runner.new(config, ref_type, ref_name, 'bin/').run

    # clean up
    FileUtils.rm_rf tmp_dir
  end
  
end
