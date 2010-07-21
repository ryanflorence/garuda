#!/usr/bin/env ruby
require 'fileutils'

class GitExtractor
  
  attr_accessor :path, :branch, :tmp_directory_path, :tar_path, :archive_path, :extracted_path
  
  # Exports a git archive
  #
  # Arguments: params (hash)
  # * path - path to git repository
  # * branch - branch to extract
  # * tmp - directory in which to create temporary files, defaults to pwd
  # * gzip - gzip the tar or not, defaults to false (defining anything will make it use gzip)
  # * verbose - turn log messages on or off, defaults to false
  # 
  # Example
  #
  #   extractor = GitExtractor.new({
  #    :path => '../path/to/repo.git',
  #    :branch => 'master',
  #    :tmp => '/Users/rpflo/Desktop',
  #    :verbose => true,
  #    :gzip => true
  #   })
  #   extractor.archive
  #   extractor.extract
  #   # do something with it
  #   extractor.cleanup
  def initialize(params={})    
    error('Path to git repository not specified in params') if params[:path].nil?
    error('Branch not specified in params') if params[:branch].nil?
    @path         = params[:path]
    @branch       = params[:branch]
    @pwd          = `pwd`.chop
    @tmp          = params[:tmp] || @pwd
    @gzip         = params[:gzip] ? '.gz' : ''
    @verbose      = params[:verbose] || false
    @archive_path = params[:archive_path] || ''
  end
    
  # Runs the `git archive` command to pull your repository out 
  # into a tar or tar.gz and writes it to a temporary directory
  #
  # Args:
  # * path - path within the repository to archive, defaults to the root
  #
  # Returns the path to the tar file
  def archive(path=nil)
    @archive_path = path || @archive_path
    @tmp_directory_path = create_tmp_directory
    @tar_path = "#{@tmp_directory_path}/archive.tar#{@gzip}"
    Dir.chdir @path
    puts "Archived repository" if run_shell_cmd "git archive --prefix=#{@archive_path}/ #{@branch}:#{@archive_path} -o #{@tar_path}" and @verbose
    Dir.chdir @pwd
  end
  
  # Extracts the archive
  # Returns the path to the extracted files
  def extract
    archive unless defined? @tar_path
    Dir.chdir @tmp_directory_path
    v = @verbose ? 'v' : ''
    cmd = @gzip == '.gz' ? "tar -x#{v}zf archive.tar.gz" : "tar -x#{v}f archive.tar"
    puts "Extracted archive" if run_shell_cmd cmd and @verbose
    Dir.chdir @pwd
    @extracted_path = "#{@tmp_directory_path}/#{@archive_path}"
  end

  # Deletes the archive.tar file created
  def remove_tar
    puts "Removed #{@tar_path}" if File.unlink @tar_path and @verbose
  end
  
  # Removes any temporary files created
  def cleanup
    puts "Removed #{@tmp_directory_path}" if FileUtils.rm_rf @tmp_directory_path and @verbose
    @tmp_directory_path = nil
    @tar_path = nil
    @archive_path = nil
    @extracted_path = nil
  end

private

  def create_tmp_directory
    # create temporary directory
    @tmp_directory_path = "#{@tmp}/tmp-#{Time.now.strftime "%Y-%m-%d-%H%M%S"}"
    puts "Made directory in #{@tmp_directory_path}" if Dir.mkdir @tmp_directory_path and @verbose
    @tmp_directory_path
  end

  # Prints the given message on stderr and exits.
  def error(msg)
    raise RuntimeError.new(msg)
  end

  # Runs the given shell command. This is a simple wrapper around Kernel#system.
  def run_shell_cmd(args)
    system(*args)
  end

end