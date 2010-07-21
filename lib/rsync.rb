# Modified (tremendously) from Nanoc's Rsync deployment script <http://nanoc.stoneship.org/>

class Rsync

  # Default rsync options
  DEFAULT_OPTIONS = [
    '-glpPrtvz',
    '--exclude=".hg"',
    '--exclude=".svn"',
    '--exclude=".git"'
  ]

  # Syncs the directories
  # Arguments:
  #   options - rysnc options
  #   dst - destination
  #   src - source files to deploy
  def run(params={})
    options = params['options'] || DEFAULT_OPTIONS
    dst = params['dst']
    src = params['src']
    error 'Destination requires no trailing slash' if dst[-1,1] == '/'
    error 'No src defined' if params['src'].nil?
    # Run
    run_shell_cmd(['rsync', options, src, dst ].flatten)
  end

private

  # Prints the given message on stderr and exits.
  def error(msg)
    raise RuntimeError.new(msg)
  end

  # Runs the given shell command. This is a simple wrapper around Kernel#system.
  def run_shell_cmd(args)
    system(*args)
  end

end
