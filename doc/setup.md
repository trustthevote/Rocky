# TODO:
Talk about:
* ruby/gemset management


# Apache config

If the gemset changes, needs to change the config paths. Stick with @rocky4 [major version] gemset


# Setup Instructions

Two things you need to do to set up your application after installing the project code.

## 1. Create real versions of the .example files
TODO

In the `rocky` application replace all the `*.example` files with real ones.  These files contain sensitive data like passwords so we don't commit them to version control.  You'll of course need to fill in the actual useful data in the real files.

  * `config/database.yml`
  * `config/newrelic.yml`
  * `config/initializers/hoptoad.rb`
  * `config/initializers/session_store.rb`
  * `db/bootstrap/partners.yml`
  
TODO
* the world of config files
config/states_with_online_registration.yml
config/app_config.yml
config/mobile.yml

config/newrelic.yml


## 2. Configure deploy scripts

* The plain .env file should just go on a workstation. It sits at the
root of project  along with .gitignore, app/, config/ etc.

## 3. Configure servers

* ssh config for github



## 4. Deploy

* how to do a setup cap X deploy:setup, cap X deploy
