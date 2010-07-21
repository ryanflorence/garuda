#!/usr/bin/env ruby

# Installation
# ------------
#
# 1. Navigate to the directory on your server where you want to install 

# 2. Run this in the terminal
# 
#      $ ruby -e "$(curl -fsS https://gist.github.com/todo: get this url)"
# 
# 3. Clone your server's gitscripts repository on your local work station. 
#    **Warning:** Don't clone the same repository as step 1, we are cloning 
#    the repository created in step 
# 
#      $ git clone ssh://user@yourserver.com//path/to/gitscripts
#
require 'rubygems'
require 'highline/import'

module Tty extend self
  def blue; bold 34; end
  def white; bold 39; end
  def red; underline 31; end
  def reset; escape 0; end
  def bold n; escape "1;#{n}" end
  def underline n; escape "4;#{n}" end
  def escape n; "\033[#{n}m" if STDOUT.tty? end
end

class Array
  def shell_s
    cp = dup
    first = cp.shift
    cp.map{ |arg| arg.gsub " ", "\\ " }.unshift(first) * " "
  end
end

def ohai *args
  puts "#{Tty.blue}==>#{Tty.white} #{args.shell_s}#{Tty.reset}"
end

def warn warning
  puts "#{Tty.red}Warning#{Tty.reset}: #{warning.chomp}"
end
 
def system *args
  abort "Failed during: #{args.shell_s}" unless Kernel.system *args
end

puts
ohai "I'm going to install gitscripts to this directory:"
pwd = `pwd`.chomp
puts "\n  #{pwd}/gitscripts\n\n"
confirm = ask("#{Tty.blue}Would you like me to continue? (yes/no):#{Tty.reset} "){ |q| q.echo = true }
abort unless confirm.downcase == ('yes' || 'y')

system "git clone ssh://rpflorence@raflorence.net/~/git/gitscripts.git"
Dir.chdir('gitscripts')
File.rename('.git/hooks/post-receive.sample', '.git/hooks/post-receive') if File.exists?('.git/hooks/post-receive.sample')
system "chmod +x .git/hooks/post-receive"
system "git config receive.denyCurrentBranch ignore"

script = %q(#!/usr/bin/env ruby
require 'rubygems'
require 'yaml'
require 'erb'

module Tty extend self
  def blue; bold 34; end
  def white; bold 39; end
  def red; underline 31; end
  def reset; escape 0; end
  def bold n; escape "1;#{n}" end
  def underline n; escape "4;#{n}" end
  def escape n; "\033[#{n}m" if STDOUT.tty? end
end

class Array
  def shell_s
    cp = dup
    first = cp.shift
    cp.map{ |arg| arg.gsub " ", "\\ " }.unshift(first) * " "
  end
end

def ohai *args
  puts "#{Tty.blue}==>#{Tty.white} #{args.shell_s}#{Tty.reset}"
end

def warn warning
  puts "#{Tty.red}Warning#{Tty.reset}: #{warning.chomp}"
end
 
def system *args
  abort "Failed during: #{args.shell_s}" unless Kernel.system *args
end

# reset the working tree
ohai "Resetting the working tree"
Dir.chdir('..')
ENV['GIT_DIR'] = '.git'
system "umask 002 && git reset --hard"

# open the config files
config        = YAML::load(File.open('config.yml'))
repo_config   = YAML::load(File.open('repos.yml'))

# Create template
template      = File.open('app/post-receive.erb')
erb           = ERB.new(template, 0, "%<>")
pwd           = `pwd`.chomp
hook_contents = erb.result
repos         = config['repositories']
unless File.directory? repos
  warn "Directory to repositories defined in config.yml does not exist. Please update config.yml and try again"
  puts "Non-existent: #{repos}"
  puts
  Process.exit
end

# install the post-receive script on all the repositories
repo_config.each do |repo, v|
  ohai "Updating hook for #{repo}"
  base_dir = "#{repos}/#{repo}.git"
  if File.exists? base_dir
    hook = "#{base_dir}/hooks/post-receive"
    unless File.exists? hook
      ohai "Renaming #{base_dir}/hooks/post-receive.sample to #{base_dir}/hooks/post-receive"
      File.rename("#{base_dir}/hooks/post-receive.sample", hook) 
    end
    ohai "chmod +x #{hook}" unless File.executable? hook
    system "chmod +x #{hook}"
    File.open(hook, 'w'){ |f| f.write(hook_contents) }
  else
    warn "Repository #{repo} is defined in repos.yml, but the directory doesn't exist."
    puts "Directory: #{Tty.white}#{base_dir}#{Tty.reset}"
    puts
  end
end
)

File.open('.git/hooks/post-receive', 'w'){ |f| f.write(script) }

puts
ohai "Installation complete"
puts
puts "#{Tty.red}Next steps:#{Tty.reset}"
puts
puts "  1. Clone this repository on your local machine"
puts
puts "     git clone ssh://user@example.net/#{pwd}/gitscripts"
puts 
puts "  2. Edit the config.yml and repos.yml files"
puts
puts "  3. Commit and push your changes."
puts
puts "     git commit -a -m 'updates'\n     git push origin master"
puts
puts "#{Tty.white}Thanks for using gitscripts, please use github issues for any bugs#{Tty.reset}"
puts