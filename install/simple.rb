#!/usr/bin/env ruby

# Installation
# ------------
#
# 1. Navigate to the directory on your server where you want to install 

# 2. Run this in the terminal
# 
#      $ ruby -e "$(curl -fsS https://github.com/rpflorence/garuda/raw/master/install/simple.rb)"
# 
#
require 'rubygems'

src = "git://github.com/rpflorence/garuda.git"

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
puts
puts "#{Tty.blue}Would you like me to continue? (type yes/no):#{Tty.reset} "
#confirm = gets
#abort unless confirm.chomp.downcase == ('yes' || 'y')

system "git clone #{src}"
Dir.chdir('garuda')
File.rename('.git/hooks/post-receive.sample', '.git/hooks/post-receive') if File.exists?('.git/hooks/post-receive.sample')
system "chmod +x .git/hooks/post-receive"
system "git config receive.denyCurrentBranch ignore"



script = %q(#!/usr/bin/env ruby
# this file is merely a "clipboard" to edit the hook and paste the text into the `simple.rb` install script

require 'rubygems'
require 'yaml'
require 'erb'

class Array
  def shell_s
    cp = dup
    first = cp.shift
    cp.map{ |arg| arg.gsub " ", "\\ " }.unshift(first) * " "
  end
end
 
def system *args
  abort "Failed during: #{args.shell_s}" unless Kernel.system *args
end

# reset the working tree
Dir.chdir('..')
puts "Resetting the working tree"
ENV['GIT_DIR'] = '.git'
system "umask 002 && git reset --hard"

# Create template
template      = File.open('install/post-receive.erb')
erb           = ERB.new(template, 0, "%<>")
garuda_dir    = `pwd`.chomp
hook_contents = erb.result

# install the post-receive script on all the repositories
Dir.open('config').each do |file|
  if file.match /\.yml$/
    repo     = file.gsub /\.yml$/, ''
    base_dir = "../#{repo}.git"

    puts "Updating hook for #{repo}"

    if File.exists? base_dir
      hook = "#{base_dir}/hooks/post-receive"

      unless File.exists? hook
        puts "Renaming #{base_dir}/hooks/post-receive.sample to #{base_dir}/hooks/post-receive"
        File.rename("#{base_dir}/hooks/post-receive.sample", hook) 
      end

      unless File.executable? hook
        puts  "chmod +x #{hook}"
        system "chmod +x #{hook}"
      end

      File.open(hook, 'w'){ |f| f.write(hook_contents) }
    else
      puts "Repository #{repo} has a configuration in config/#{repo}.yml, but the repository doesn't exist in:"
      puts "Directory: #{base_dir}"
      puts
    end

  end
end

)


File.open('.git/hooks/post-receive', 'w'){ |f| f.write(script) }
# get back out of garuda
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
puts "  2. Create config files with names that match their repositories in config/"
puts
puts "     config/awesome.yml  # => matches awesome.git"
puts
puts "  3. Commit and push your changes"
puts
puts "     git commit -a -m 'updates'\n     git push origin master"
puts
puts "#{Tty.white}Thanks for using Garuda, please use github issues for any bugs#{Tty.reset}"
puts