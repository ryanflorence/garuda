Garuda - Git deployment for the over-served
===========================================

Garuda is a git-hosting-server-side ruby library of scripts used to deploy multiple repositories to multiple web servers.  It lives on the server where your repositories are hosted and requires no client or destination server software.  It is ideal for web shops that maintain numerous websites.

Once Garuda is installed and configured, deployment is automatic whenever a developer pushes a branch or tag that matches against your configuration files--so you can stop delaying QA or releases over deployment (not to mention giving all your client's passwords out to every developer in the shop.)

It isn't just for deployment either.  You can set up scripts to email your team or generate an rss feed somewhere whenever a repository receives new commits.

Garuda does not, however, concern itself with the destination servers beyond putting files on them (think Capistrano).  But there's nothing stopping you from writing scripts that do perform tasks on the destination servers.

Example
-------

In the `repos.yml` file you define some things about your repositories:

	example.com:
    heads:
      master:
        script: rsync
        destination: user@example.com:~/production
      develop:
        script: ftp
        server: 12.345.678.91
        user: username
        password: password
        destination: './dev.example.com'
        os: windows
    tags:
      '^RC.+':
        script: rsync
        destination: user@example.com:~/stage

Now, whenever a developer pushes to master in example.com.git:

	$ git push origin master

Garuda will pick up that you want to run the rsync script, which extracts out the master branch of your repository and syncs up the files with the destination folder.

If a user pushes to the develop branch, it will run the ftp script, passing along a user name and password and uploading all of the files to the windows server.

And finally if anybody pushes a tag that starts with `RC` it will sync that tag up with the staging server.

You can write your own scripts, too, I've only got the ones we needed in our shop to push to linux (rsync, ftp) and windows servers (ftp).

More documentation to come.

Installation
------------

Garuda is simply a git repository on your server, installed anywhere you want. If you don't want it later, just remove the directory.  It assumes you use git as your scm, and that you put all of your repositories in one place (since you should be using gitolite or gitosis anyway.)

1. On the server where your repositories are hosted, navigate to the directory where you want to install Garuda.  It can be, but doesn't have to be, the same directory as your repositories.

		$ ssh user@yourserver.com
		$ cd desired/path/

2. Copy and paste this:

		$ ruby -e "$(curl -fsS https://gist.github.com/4931616e67a28849747e)"

	Go ahead and `ls` to see what was installed.

3. Clone your server's garuda repository on your local work station. **Warning:** Don't clone the same repository as step 1, we are cloning the repository created in step 2

		$ git clone ssh://user@yourserver.com//desired/path/garuda

Administration
--------------

Garuda is administered completely with git.  You shouldn't ever edit the repository on your server.  Instead, edit your local clone and just push.  As usual, it's a good idea to pull before making changes if you've got other people also administering the files.

1. On your local machine, edit `config.yml` and `repos.yml`

2. Commit and push your changes to origin

		$ git commit -a -m 'updated configurations'
		$ git push origin master

Writing your own scripts
------------------------

Place any scripts you want to run in /bin.  The /lib directory is available as a place to put scripts that aren't called directly but used in the bin scripts.

License
-------

Garuda is licensed under the MIT license.  Please fork and contribute!