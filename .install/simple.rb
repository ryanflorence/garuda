#!/usr/bin/env ruby

# Installation
# ------------
#
# 1. Navigate to the directory on your server where you want to install 

# 2. Run this in the terminal
# 
#      $ ruby -e "$(curl -fsS http://github.com/rpflorence/garuda/raw/master/.install/install.rb)"
# 
# 3. Clone your server's garuda repository on your local work station. 
#    **Warning:** Don't clone the same repository as step 1, we are cloning 
#    the repository created in step 
# 
#      $ git clone ssh://user@yourserver.com//path/to/garuda
#
# 4. Update config.yml and repos.yml and push
#
#      $ git push origin master
#
require 'rubygems'
require 'highline/import'

#src = "git@github.com:rpflorence/garuda.git"
src = "ssh://rpflorence@raflorence.net/~/git/garuda.git"

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
ohai "I'm going to install garuda to this directory:"
pwd = `pwd`.chomp
puts "\n  #{pwd}/garuda\n\n"
confirm = ask("#{Tty.blue}Would you like me to continue? (yes/no):#{Tty.reset} "){ |q| q.echo = true }
abort unless confirm.downcase == ('yes' || 'y')

system "git clone #{src}"
Dir.chdir('garuda')
File.rename('.git/hooks/post-receive.sample', '.git/hooks/post-receive') if File.exists?('.git/hooks/post-receive.sample')
system "chmod +x .git/hooks/post-receive"
system "git config receive.denyCurrentBranch ignore"

script = %q(#!/usr/bin/env ruby
# this becomes the post-receive hook of the server's garuda repository, pasted as text into install.rb

require 'rubygems'
require 'yaml'
require 'erb'

# run this script from garuda repository root
Dir.chdir('..')

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
ENV['GIT_DIR'] = '.git'
system "umask 002 && git reset --hard"

# Create template
template      = File.open('.install/post-receive.erb')
erb           = ERB.new(template, 0, "%<>")
garuda_dir    = `pwd`.chomp
hook_contents = erb.result

# install the post-receive script on all the repositories
Dir.open('config').each do |file|
  if file.match /\.yml$/
    repo     = file.gsub /\.yml$/, ''
    base_dir = "../#{repo}.git"

    ohai "Updating hook for #{repo}"

    if File.exists? base_dir
      hook = "#{base_dir}/hooks/post-receive"

      unless File.exists? hook
        ohai "Renaming #{base_dir}/hooks/post-receive.sample to #{base_dir}/hooks/post-receive"
        File.rename("#{base_dir}/hooks/post-receive.sample", hook) 
      end

      unless File.executable? hook
        ohai  "chmod +x #{hook}"
        system "chmod +x #{hook}"
      end

      File.open(hook, 'w'){ |f| f.write(hook_contents) }
    else
      warn "Repository #{repo} has a configuration in config/#{repo}.yml, but the repository doesn't exist in:"
      puts "Directory: #{Tty.white}#{base_dir}#{Tty.reset}"
      puts
    end

  end
end
)

File.open('.git/hooks/post-receive', 'w'){ |f| f.write(script) }

Dir.chdir('..')

puts
ohai "Installation complete"
puts
puts "#{Tty.red}Next steps:#{Tty.reset}"
puts
puts "  1. Clone this repository on your local machine"
puts
puts "     git clone ssh://user@example.net/#{pwd}/garuda"
puts 
puts "  2. Edit the config.yml and repos.yml files"
puts
puts "  3. Commit and push your changes."
puts
puts "     git commit -a -m 'updates'\n     git push origin master"
puts
puts "#{Tty.white}Thanks for using garuda, please use github issues for any bugs#{Tty.reset}"
puts