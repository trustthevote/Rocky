# TODO:
Talk about:
* ruby/gemset management


# Apache config

If the gemset changes, needs to change the config paths. Stick with @rocky4 [major version] gemset


# Development Setup Instructions


## 1. Create real versions of the .example files


### a. Ruby version management

The `rocky` application is setup assuming you're using RVM. The ruby version and gemset name are stored in the `.ruby-version` and `.ruby-gemset` files which should set your RVM environment automatically. If you're using a ruby version manager other than RVM you'll need to make changes to the deploy process.


### b. Customizing files

In the `rocky` application replace all the `*.example` files with real ones.  

These files contain sensitive data like passwords so we don't commit them to version control.  You'll of course need to fill in the actual useful data in the real files. See the contents of the example files for details on how they're used.

  * `config/database.yml`
  * `config/newrelic.yml`
  * `config/initializers/cookie_verification_secret.rb`
  * `db/bootstrap/partners.yml`
  * `.env.[environment_name]` for example, .env.staging or .env.production
  
These files contain configuration items that differ from environment to environment. If you don't create your own version on the server a version of these files will be created automatically in the first deploy.

  * `config/states_with_online_registration.yml` - the list of states that have a separate workflow for redirection to their own online system.
  * `config/app_config.yml` - general settings for app behavior (mostly email and cleanup timings)
  * `config/mobile.yml` - configuration items for mobile detection behavior



## 2. Configure deploy scripts

The `rocky` application is set up to be deployed using capistrano with multistage.
The repository contains the generic `config/deploy.rb` file with the main set of procedures for a deployment and there are a number of environment-specific files in `config/deploy/`. These files just contain a few settings which reference environment variables. These variables need to be set in your .env file (which only needs to exist on your development machine, or wherever you run your cap scripts from). See .env.example for a list of what values need to be specified.

* The plain .env file should just go on a workstation. It sits at the
root of project  along with .gitignore, app/, config/ etc.



## 3. Configure servers

* ssh config for github



## 4. Deploy

### a. Setup (rvm/passenger)

### b. Deploy (various symlinks)


* how to do a setup cap X deploy:setup, cap X deploy



# Additional Notes

* The set of files for config is likely to change