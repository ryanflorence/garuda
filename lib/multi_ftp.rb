#! /usr/bin/ruby
# Tyler Clemons June 13, 2008
# Multiple FTP Upload v 1.0
# Reads in specified directory(s) and uploads all files and folders to a server
# Developed on Mac OS X 10.4  and Ruby 1.8.6 
# Should work on Windows might need to change the slash directions for local directories...
# ...can change in the initialize function under @os_slash
# Distributed under the GNU GENERAL PUBLIC LICENSE
  
# Note by Ryan Florence: this is a little ugly, but effective, will rewrite soon.
# Added some stuff to get windows to behave

#---------------------------------------------------------------------
require 'net/ftp'
#---------------------------------------------------------------------
class MultiFTP
  'basic permissions are expected, such as the ability to create, view, and delete directories'
  attr_accessor :username, :server, :password, :attempts
  
  #-------------------------------------------------------------------
  def initialize(os = 'windows')  
    @os = os
    @username = ""
    @password = ""
    @server = ""
    @ftp = Net::FTP.new()
    @attempts = 5
    @remote_directory = "."
    @local_directory = ""
    @directorys = {}
    @current_directory = [[],[]] #[local,remote] directory
    @error_files = []
    @remote_home = ""
    @connected = false
    @logged_in = false
    @fcount = 0
    @dcount = 1

    #change for different OS
    @os_slash = "/"
    
  end
  #-------------------------------------------------------------------
  def return_home()
    'returns the ftp instance to the remote home directory call this
    if u plan on using the same instance on different folders'
    
    if not @ftp.closed?
      
      @ftp.chdir(@remote_home)
      puts "Changed to Home directory #{@remote_home}"
        
    end
    
  end
  #-------------------------------------------------------------------
  def delete_directory(remote)
    'deletes a directory on a server, remote is the directory.
    a proper directory parameter will have the entire path ie.
    ./d1/kill me   where kill me is the directory that will die and ./ is
    the current directory.'
    
    @dcount = 0
    remote = remote[1..-1] if remote[0] == 47
    if check_connection()
      @current_directory[1] = [remote]
      kill_directory()
    end
    
    puts "Task Completed.  #{@fcount} files and #{@dcount} directories deleted"
    @fcount = 0
    @dcount = 1
    return_home()
  end

  
  #-------------------------------------------------------------------
  def go_send(local="/.",remote="/.")
    'call this after the connection is completed, 
     pass in the directories that will be transfered. For defaults, use "/."
     for others, use (/pub/local,/pub/remote) where remote is the parent-to-be
     directory of local'
    
    if check_connection()
      
      local = "#{@os_slash}#{local}" if local[0] != @os_slash[0] 
      @current_directory[0] = [local]
      remote = "/#{remote}" if remote[0] != 47   and remote[0] != 46
      remote = "#{remote[0..-2]}" if remote[-1] == 47
      @current_directory[1] = [remote]
      
      check_remote_directory()
      send_it()
    
      #finished so print stuff
      puts "Completed sending #{local} to #{remote}."
      puts "Transmitted #{@fcount} files in #{@dcount} directories with #{@error_files.size()} errors."
      @error_files.each { |x| puts "Did not send, #{x}"}
      @fcount = 0
      @dcount = 1
      return_home()
    end
  end
  #-------------------------------------------------------------------
  def go_get(local="/.",remote="/.")
    'call this after the connection is completed, 
     pass in the directories that will be received. For defaults, use "/."
     for others, use (/pub/local,/pub/remote) where local is the parent-to-be
     directory of remote files'
    
    if check_connection()
      remote = remote[1..-1] if remote[0] == 47

      @current_directory[1] = [remote]
      
      #the first assigment is for those that specify a folder
      #the second is for defaults
      local = "#{@os_slash}#{local}" if local[0] != @os_slash[0]   #if it does not have a slash
      local = Dir.pwd + "#{@os_slash}#{remote.split("/")[-1]}" if local == "#{@os_slash}."
      
      @current_directory[0] = [local]
      check_local_directory()
   
      get_it()
      
      #finished so print stuff
      puts "Completed receiving #{remote} to #{local}."
      puts "Transmitted #{@fcount} files in #{@dcount} directories with #{@error_files.size()} errors."
      @error_files.each { |x| puts "Did not send, #{x}"}
      @error_files = []
      @fcount = 0
      @dcount = 1
      return_home()
    end
  end
  #-------------------------------------------------------------------
  def close_ftp()
    'closes ftp connection'
    @ftp.close
  end
  #-------------------------------------------------------------------
  def setup(server,username,password)
    'pass in username,password,and server for credentials'

    #need these for a possible reconnection
    @server = server
    @username = username
    @password = password
    setup_connect()
  end
  #-------------------------------------------------------------------
 
  #-------------------------------------------------------------------
  def get_it()
    'this is called by the class and not the user'
    @ftp.chdir(@current_directory[1][-1])
    puts "Changed to remote directory #{@current_directory[1][-1]}"
    
    #grab entries out of local directory
    local_list = Dir.entries(".")
    file_list = get_files_and_directories()
    file_list.each { |thefile|
      filename = thefile[0]
      #if this is a File, the second element if True
      if thefile[1]
        
        begin
          print "Attempting to get #{filename}..."
          @ftp.getbinaryfile(filename,filename)
          puts "Got it!"
          @fcount += 1
        rescue
            if save_get(filename) == true
              redo
            else
              puts "Error getting file, #{filename}, moving on"
              @error_files << @current_directory[0][-1] + "/#{filename}"
            end
        end
      #handle directories
      else
         #make sure not to touch current and parent
         
        if not local_list.index(filename)
          Dir.mkdir(filename)
          puts "Made Local Directory #{filename}"
        end
        Dir.chdir(filename)
        @dcount += 1
        @current_directory[0] << filename
        @current_directory[1] << filename
        puts "Changed to Local directory #{filename}"
        get_it()

        #move onto next file
        @ftp.chdir("..")
        @current_directory[1].pop
        puts "Changed to remote parent directory #{@current_directory[1][-1]}"
        Dir.chdir("..")
        @current_directory[0].pop
        puts "Changed to local parent directory #{@current_directory[0][-1]}"
        
      end
      }
  end
  #-------------------------------------------------------------------
  def send_it()
     
    Dir.chdir(@current_directory[0][-1])
    puts "Changed to local directory #{@current_directory[0][-1]}"
    
    remote_list = get_files_and_directories()
    
    Dir.entries(".").each { |thefile|
      #be sure not to try and send the current and parent directory "." and ".."
      if thefile != "." and thefile != ".." 
        #check if this is a file
        filename = File.basename(thefile)
        if not File.directory?(thefile)
          begin
          print "Attempting to send #{thefile}..."
          @ftp.putbinaryfile(thefile,thefile)
          @fcount += 1
          puts "Sent!"
          rescue
            if save_send(thefile) == true
              redo
            else
              puts "Error sending file, #{filename}, moving on"
              @error_files << @current_directory[0][-1] + "/#{filename}"
            end   
          end
        else  
          #this is a directory, now check if it is on the server
          #if not, make it
          if not remote_list.index([filename,false])
            @ftp.mkdir(filename)
            puts "Made remote directory #{filename} "
          end
          
          #change directory and make recursive call
          @ftp.chdir(filename)
          @current_directory[0] << filename
          @current_directory[1] << filename
          puts "Changed to remote directory #{filename}"
          send_it()
          
          #move onto next file after sending directory
          @ftp.chdir("..")
          @dcount += 1
          @current_directory[1].pop
          puts "Changed to remote parent directory #{@current_directory[1][-1]}"
          Dir.chdir("..")
          @current_directory[0].pop
          puts "Changed to local parent directory #{@current_directory[0][-1]}"

        end
      end
      }
  end
  #-------------------------------------------------------------------
  def kill_directory()
    'this is called by the class and not the user'
    
    #change directory, the last is any found directory stored via recursion
    @ftp.chdir(@current_directory[1][-1])
 
    file_list = get_files_and_directories()
 
    file_list.each { |thefile|
      filename = thefile[0]
      
       #Files are True
       if thefile[1]
        print "Attempting to delete file #{filename}..."
        @ftp.delete(filename)
        @fcount += 1
        puts "Deleted!"
            
      #handle directories
      else
         if filename != "." and filename != ".."
           #recursive call on found directory
           @current_directory[1] << filename
           kill_directory()
        end
      end
    }
    #all files and subfolders of a directory are deleted now kill current
    print "Attempting to delete directory #{@current_directory[1][-1]}..."
    @ftp.chdir("..")
    begin
      @ftp.rmdir(@current_directory[1][-1])
      @dcount += 1
      puts "Deleted!"
    rescue
      puts "Cannot delete directory #{@current_directory[1][-1]}"
    ensure
      @current_directory[1].pop
      
    end
  end
  #-------------------------------------------------------------------
  def save_send(thefile)
    'called by the class and not the user'
    #attempt to save a send operation
    
    if @ftp.closed?
      puts "Connection closed attempting to reopen"
      if setup_connect() == true
        @ftp.chdir(@current_directory[1].collect{|x|x+"/"}.to_s)
        return true
      else
        return false
      end
    end
    
  end
  #-------------------------------------------------------------------
  def save_get(thefile)
    'called by the class and not the user'
    #attempt to save a get operation
    
    if @ftp.closed?
      puts "Connection closed attempting to reopen"
      if setup_connect() == true
        @ftp.chdir(@current_directory[1].collect{|x|x+"/"}.to_s)
        return true
      else
        return false
      end
    end
    
  end
  #-------------------------------------------------------------------
  def check_remote_directory()
    'used to change the remote directory upon a connection
    to work correctly, pass a directory using this format: 
    ./directory/parent_directory so that the local directory will be written
    to the parent_directory' 
    
    @current_directory[1][0].split("/").each {|r_direct|
    if r_direct != ""
      file_list = get_files_and_directories()
      if not file_list.index([r_direct,false]) and r_direct != "." and r_direct != ".."
        @ftp.mkdir(r_direct)
        puts "Made remote directory #{r_direct}"
      end
      @ftp.chdir(r_direct)
      puts "Changed to remote directory #{r_direct}"
    end
    }

  end
  #-------------------------------------------------------------------
  def check_local_directory()
    'This method only assumes that the final directory is the destination'
    
    local_directories = @current_directory[0][0].split("#{@os_slash}")[1..-1]
    lsize = local_directories.size-1
   
    dir = ""
    lsize.times {|directory|
      dir += "#{@os_slash}#{local_directories[directory]}"
    }

    Dir.chdir(dir)
    puts "Changed to local directory #{dir}"
    if not Dir.entries(".").index(local_directories[-1])
      Dir.mkdir(local_directories[-1]) 
      puts "Made directory #{local_directories[-1]}"
    end
    Dir.chdir(local_directories[-1])
    puts "Changed to local directory #{local_directories[-1]}"

  end
  #-------------------------------------------------------------------
  def setup_connect()
    'connects to server, called by the class user should use setup'

    @connected = false
    @logged_in = false
   
    @attempts.times { |n|
      #connect to server
      begin
      @ftp.connect(@server)
      @connected = true
        puts "Connected to server #{@server}"
        break
      rescue
        puts "Cannot connect to server...retrying(#{n+1})"
        sleep(3)
        next
      end
    }
    #login to server
    if @connected == true
      @attempts.times { |n|
        begin
          @ftp.login(@username,@password)
          puts "Logged into server #{@server}"
          @logged_in = true
          @remote_home = @ftp.pwd
          break
        rescue 
          puts "Cannot login to server...retrying(#{n+1})"
          sleep(3)
          next
        end
      }
    end
  return @logged_in
  end
  #-------------------------------------------------------------------
  def get_files_and_directories()
    'this function gets the list of files and directories and 
     returns a list of [filename,True if file]'
    all_list = []
    @ftp.ls("-a").each{|thefile|
      if @os == 'windows'
        filename = thefile.split(' ')[-1]
        if thefile.match('<DIR>')
          all_list << [filename, false]
        else
          all_list << [filename, true]
        end
      else
        if thefile.size() > 8
          filename = ""
          filehold = thefile.split(" ")[8..-1] #get filename or directory name
          filehold.each {|name_segment| filename += " #{name_segment}" }
          filename.lstrip!
          #if this is a directory a d or ASCII 100 will be the first character
          #45 means its just a file
          #anything else is garbage
          if filename != "." and filename != ".."
            if thefile[0] == 45
              all_list << [filename,true]
            elsif thefile[0] == 100
              all_list << [filename,false]
            end 
          end
          
        end
      end
    }
    
    return all_list
  end
  #-------------------------------------------------------------------
  def check_connection()
    #checks if a connection has been made called each time an operation is
    #requested
    
    if @connected == true and @logged_in == true
      if not @ftp.closed?
        return true
      else
        puts "FTP session closed now attempting to reconect..."
        if setup_connect() == true
          return true
        else
          puts "Could not reconnect"
          return false
        end
      end
    else
      puts "Connection not established! Call setup before attempting
            and operation!"
      return false
    end
  end
  #-------------------------------------------------------------------
end
#-------------------------------------------------------------------
