class Runner
  
  # config (hash) - Scripts, each with a hash of the script name and its args
  # ex.
  #   rsync:
  #     destination: some/path
  #     root: the/root/
  #   rename:
  #     from: somefile.dev
  #     to: somefile
  def initialize(config, ref_type, ref_name, script_path = ENV['PWD'])
    @config      = config
    @ref_type    = ref_type
    @ref_name    = ref_name
    @script_path = script_path
  end
  
  def run
    Dir.chdir(@script_path)
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
          system("./#{script}")
          # clear ENV
          args.each { |k,v| ENV[k] = nil }
        end
      end
    end
    
    Dir.chdir(ENV['PWD'])
  end
  
  
    
end