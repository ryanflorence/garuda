Garuda - automated deployment 
=============================

#### and git post-receive hook script runner


Who can benefit from Garuda?
----------------------------

Anybody who deploys several websites and applications to several servers stand to benefit the most.  But anybody who hosts git repositories remotely will also find Garuda to be helpful.

What is Garuda?
---------------

When a user pushes to a remote git repository, Garuda manages which scripts you'd like to run and which environment variables you'd like to be available.  All of this is defined in a config file for the repository.

### A config example file

    # config/awesome_site.yml
    
    heads:
      develop:
        deploy/rsync:
          source: htdocs/
          destination: user@domain.com:/home/user/dev/htdocs
    
    tags:
      # Matches 1.2.2-RC1, 2.12.1-RC2 etc.
      '^[0-9]+.[0-9]+.[0-9]+-RC[0-9]+$'
        deploy/rsync:
          source: htdocs/
          destination: user@domain.com:/home/user/staging/htdocs
      
      # Matches 1.2.2, 2.12.1, etc.
      '^[0-9]+.[0-9]+.[0-9]+$':
        util/rename:
          htaccess.production: .htaccess
        deploy/ftp:
          source: htdocs
          destination: ./user/production/htdocs
          host: 111.11.1.11
          user: joe
          pass: shcmoe

Installation
------------

### Gitosis / Gitolite setups

1. Add garuda to your conf file, then clone it locally
2. Navigate to the home directory of your gitosis / gitolite user on your server
3. Run this in the terminal (on the server as the git user, otherwise use sudo)

        ruby -e "$(curl -fsS https://github.com/rpflorence/garuda/raw/master/install/gito.rb)"

4. If you used `sudo` in step 3, change the ownership to your gitolite / gitosis user (here it's git, use whatever yours is)

        sudo chown -R git garuda

### Simple setup

1. Navigate to the directory on your server where you want to install
2. Run this in the terminal

        ruby -e "$(curl -fsS https://github.com/rpflorence/garuda/raw/master/install/simple.rb)"

Writing scripts
---------------

1.  Write scripts that do stuff and put them in `bin/`
2.  Use the `lib/` directory for scripts that require extra logic (`bin/` scripts should rarely do more than a couple of lines.)
3.  `bin/` scripts must be executable `chmod +x bin/file`

_sample yaml_

    # config/awesome_site.yml
    heads:
      develop:
        'deploy/rsync':
          src: 'htdocs/'
          dst: 'user@domain.com:/home/user/site/htdocs'
    tags:
      '^[0-9]+.[0-9]+.[0-9]+$':
        rename:
          htaccess.production: .htaccess
        'deploy/ftp':
          src: 'htdocs'
          server: 111.11.1.11
          user: joe
          pass: shcmoe
          dst: './public_html'
          

If a user pushes a branch like this: `$ git push origin develop`, on the server, Garuda will:

1. Check out the `develop` branch of the repository 
2. Set two environment variables: `src` and `dst`
3. And finally run the `bin/deploy/rsync` script.

If a user instead pushes a tag like this: `$git push origin 2.1.3`, then Garuda will check out the tag 2.1.3, because it matches the regex yaml key under `tags`, set the environment variables and call each script.

It always checks for a regex match.  So pushing branches like "develop" and "develop-topic" both match `/develop/`, and, in this case, would both execute the `deploy/rsync script`.  This can be prevented with a stricter key like `^develop$`, which would be an exact match for a branch named "develop".

Though YAML provides a number of data types, environment variables can only be strings, so keep it to key:value pairs.  If you need more than that, you'll need to parse the string in your bin script like any good shell script does.
