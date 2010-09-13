class Runner
  
  # config (hash) - Scripts, each with a hash of the script name and its args
  # ex.
  #   rsync:
  #     destination: some/path
  #     root: the/root/
  #   rename:
  #     from: somefile.dev
  #     to: somefile
  def initialize(config, script_path = ENV['PWD'])
    @config      = config
    @script_path = script_path
  end
  
  def run
    Dir.chdir(@script_path)
    @config.each do |script, args|
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
      system("./#{script}")
      # clear ENV
      args.each { |k,v| ENV[k] = nil }
    end
    Dir.chdir(ENV['PWD'])
  end
    
end