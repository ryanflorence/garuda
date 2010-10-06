require 'rubygems'
require 'yaml'
require 'fileutils'

class Garuda

  attr_accessor :tree, :config

  def initialize()
    # set from hook, or when `run` script is called manually with ARGV
    @repository = ENV['repository'] || ARGV[0] 
    @ref_type   = ENV['ref_type']   || ARGV[1] 
    @ref_name   = ENV['ref_name']   || ARGV[2]
    @config     = YAML::load(File.open("config/#{@repository}.yml"))
    @root       = Dir.pwd
  end

  def clone_repository
    @tmp_dir = 'tmp/' + Time.now.strftime("%Y%m%d%H%M%S")
    Dir.mkdir 'tmp' unless File.directory?('tmp')
    Dir.mkdir(@tmp_dir);
    Dir.chdir(@tmp_dir);
    `git clone ../../../#{@repository}.git`
    Dir.chdir(@repository)
    @tree = ENV['tree'] = Dir.pwd
    Dir.chdir(@root);
    self
  end

  def run
    # run the scripts from the tmp repository's directory tree root
    Dir.chdir(@tree)
    # Can match multiple ref_types, so we loop them
    @config[@ref_type].each{ |key, data| self.execute key if @ref_name.match /#{key}/ }
    Dir.chdir(@root)
    self
  end

  def execute(key)
    @config[@ref_type][key].each do |script, args|
      puts "# Running script: " + script
      self.set_args args if args
      system("#@root/bin/#{script}")
      # clear env vars
      args.each { |k,v| ENV[k] = nil } if args
    end
  end

  def set_args(args)
    args.each do |k,v|
      if ENV[k] != nil
        puts "ENV['#{k}'] is already defined as #{ENV[k]}, please change the name of your key. Aborting."
        abort
      end
      # assign it to env
      ENV[k] = v.to_s
    end
  end

  def cleanup
    FileUtils.rm_rf @tmp_dir
    self
  end

end
