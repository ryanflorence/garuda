Garuda deployment and git post-receive script runner
====================================================

Who can benefit from Garuda?
----------------------------


Installation
------------

  ruby -e "$(curl -fsS http://github.com/rpflorence/garuda/raw/master/.install/install.rb)"


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
