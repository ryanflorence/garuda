#!/usr/bin/env ruby

# Installation
# ------------
#
# 1. Add garuda to your conf file, then clone it locally
# 
# 2. Navigate to the home directory of your gitosis / gitolite user on your server

# 3. Run this in the terminal (on the server)
# 
#      $ ruby -e "$(curl -fsS http://github.com/rpflorence/garuda/raw/master/.install/gito-install.rb)"
# 
# 4. Pull changes from gitosis / gitolite to your local clone
# 
#      $ git pull origin master
#
# 5. Update config.yml and repos.yml and push
#
#      $ git push origin master
#
require 'rubygems'

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
ohai "I'm going to try to install garuda for a gitosis / gitolite setup:"
puts
puts "#{Tty.blue}Would you like me to continue? (type yes/no):#{Tty.reset} "
confirm = gets
puts confirm
abort unless confirm.chomp.downcase == ('yes' || 'y')

pwd = `pwd`.chomp

unless File.directory?("#{pwd}/garuda.git")
  puts "#{Tty.red}Error#{Tty.reset}: I tried to find #{pwd}/garuda.git, but didn't."
  puts
  puts "  1. Add garuda to your gitosis or gitolite conf file, then clone it locally."
  puts "  2. Try this install again from the gitosis/gitolite users's directory."
  puts
end

# clone source
system "git clone git://github.com/rpflorence/garuda.git"
Dir.chdir('garuda')

# add gitosis/gitolite repo as a remote and push
system "git remote add gito #{pwd}/garuda.git"
system "git push gito master"

# install the hook on the bare repository
Dir.chdir("#{pwd}/garuda.git")
File.rename('hooks/post-receive.sample', 'hooks/post-receive') if File.exists?('hooks/post-receive.sample')
system "chmod +x hooks/post-receive"

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
ohai "Updating the clone's working tree"
Dir.chdir('../garuda')
ENV['GIT_DIR'] = '.git'
system "umask 002 && git pull gito master"

# open the config files
config        = YAML::load(File.open('config.yml'))
repo_config   = YAML::load(File.open('repos.yml'))

# Create template
template      = File.open('.install/post-receive.erb')
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

File.open('hooks/post-receive', 'w'){ |f| f.write(script) }

puts
ohai "Installation complete"
puts
puts "#{Tty.red}Next steps:#{Tty.reset}"
puts
puts "  1. In your local workign tree, pull changes from gitosis / gitolite remote repository"
puts
puts "     git pull origin master"
puts 
puts "  2. Edit the config.yml and repos.yml files"
puts
puts "  3. Commit and push your changes."
puts
puts "     git commit -a -m 'updates'\n     git push origin master"
puts
puts "#{Tty.white}Thanks for using garuda, please use github issues for any bugs#{Tty.reset}"
puts