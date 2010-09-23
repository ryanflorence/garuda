require 'rubygems'
require 'yaml'
require 'fileutils'

class Garuda
  
  attr_accessor :tree
  
  def initialize
    # set variables
    @repository = ENV['repository'] = ARGV[0] || ENV['repository']
    @ref_type   = ENV['ref_type']   = ARGV[1] || ENV['ref_type']
    @ref_name   = ENV['ref_name']   = ARGV[2] || ENV['ref_name']
    @config     = YAML::load(File.open("config/#{@repository}.yml"))
  end
  
  def clone_repository
    @tmp_dir = 'tmp/' + Time.now.strftime("%Y%m%d%H%M%S")
    Dir.mkdir(@tmp_dir);
    Dir.chdir(@tmp_dir);
    # in /tmp/timestamp/
    `git clone ../../../#{@repository}.git`
    Dir.chdir(@repository)
    @tree = ENV['tree'] = Dir.pwd
    # go back to /
    Dir.chdir('../../..');
    self
  end
  
  def run
    Dir.chdir(@tree)
    # Can match multiple ref_types, so we loop them
    @config[@ref_type].each do |key, data|
      # check if our ref_type matches the key in the config file
      if @ref_name.match(/#{key}/)
        # matched, run the scripts under that ref_name
        @config[@ref_type][key].each do |script, args|
          puts "# Running script: " + script
          args.each do |k,v|
            # check if key already exists in ENV
            if ENV[k] != nil
              puts "ENV['#{k}'] is already defined as #{ENV[k]}, please change the name of your key. Aborting."
              Process.exit();
            end
            # assign environment variable
            ENV[k] = v.to_s
          end
          # execute the script
          system("./../../../bin/#{script}")
          # clear ENV
          args.each { |k,v| ENV[k] = nil }
        end
      end
    end
    
    Dir.chdir('../../../')
    self
  end
  
  def cleanup
    # clean up
    FileUtils.rm_rf @tmp_dir
    self
  end
  
end
