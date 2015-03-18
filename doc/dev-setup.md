# Development Setup Instructions


## 1. Ruby version management

The `rocky` application is setup assuming you're using RVM (https://rvm.io/). The ruby version and
gemset name are stored in the `.ruby-version` and `.ruby-gemset` files which
should set your RVM environment automatically. If you're using a ruby version
manager other than RVM you'll need to make changes to the deploy process.

## 2. Customizing files

In the `rocky` application replace all the `*.example` files with real ones.

The following files contain sensitive data like passwords so we don't commit them to
version control. You'll of course need to fill in the actual useful data in the
real files. See the contents of the example files for details on how they're
used.

  * `config/database.yml`
  * `config/newrelic.yml`  # For development purposes you do not need to fill in real data here
  * `db/bootstrap/partners.yml` # For development purposes you can copy the example file exactly and use the password 'passwod'
  * `.env.[environment_name]` for example .env.development or .env.production
  
There are a number of files used by the `rails_config` gem - `config/settings.yml`
and all the files under `config/settings/`. These are checked into source
control and should be reviewed to ensure the application functions as you expect. 
They don't contain sensitive information, but have values that are specific to the environment and instance
of the `rocky` application being deployed. See the rocky-settings.md file for an explanation of
all of the options.



### 2a. Importing State Data

Basic state data is stored in `db/bootstrap/states.yml`. This file does not need to be changed and will 
get imported during the db:bootstrap process described in #3. However, data on county-specific addresses 
and zip-code-to-county mappings can be retrieved via the eod.usvotefoundation.org API along with the 
the USPS zip code database placed in `data/zip_codes/zip_code_database.csv``. All of the 
mapping can be computed via

    $ rake import:build_county_address_csv
    
Then to import the mapping of counties and zip codes to the database, run

    $ rake import:states_and_zips


Whenever the states.yml file is updated you'll want to run

    $ rake import:states

## 3. Getting the app to run locally

Once RVM is installed (and the appropriate ruby version and gemset have been set
up) and all of the example .yml and .env files have been turned into the real
versions, run:

    $ gem install bundler
    $ bundle install
  
If the database hasn't been created yet, set that up by running

    $ bundle exec rake db:create
    $ bundle exec rake db:migrate
    $ bundle exec rake db:bootstrap  
    
    # db:bootstrap is important - there must be at least one partner present for the app to function
    # then run ONE of the following depending on how you want county/zip-code addresses to be handled
    
    $ rake import:states
    $ rake import:sttes_and_zips



# Testing

The cucumber feature that exercises the PDF Merge will run either in-process, or
with the daemon. If the daemon is running, it will use that. If the daemon is
not running, it will shell out to java to run the merge directly.

Run the rspec test suite:

    $ bundle exec rspec spec/

Run the features with cucumber:

    $ bundle exec cucumber

## 1. Load Testing

### 1a. From the development workstation

There is a script at spec/api_load_test.rb that can run multi-threaded tests against the registration API.
In the file, edit the config section at the top to specify the number of threads and requests-per-thread
and other details like which server to test. 

The next section of the file is a method for viewing the PDF queue status. Log into a machine
that has access to the application and the queue data base and start a rails console. Copy the view_queue
method into the console and then run the method. This will show a queue status every 5 seconds and also calculate
a run off time for a maximal number of PdfGenerations in the queue.

Once you have the monitor running, run the load test script via

    $ bundle exec ruby spec/api_load_test.rb
    
    
### 2a. Loader.io
    
You can also do more extensive load tests with loader.io. You'll need to create an account and 
verify the host you're testing against. Then create a new scenario with the Client Requests section set to

    method: POST 
    protocol: https
    host: [the host you're testing]
    path: api/v3/registrations.json?registration%5Bdate_of_birth%5D=11-05-1955&registration%5Blang%5D=en&registration%5Bcollect_email_address%5D=no&registration%5Bfirst_name%5D=firststage%20&registration%5Bmiddle_name%5D=middlestage&registration%5Blast_name%5D=lastStage&registration%5Bhome_address%5D=101%20Address%201&registration%5Bhome_unit%5D=420&registration%5Bhome_city%5D=Waltham&registration%5Bhome_state_id%5D=MA&registration%5Bhome_zip_code%5D=02453&registration%5Bname_title%5D=Mr.&registration%5Bpartner_id%5D=7&registration%5Bparty%5D=Democratic&registration%5Brace%5D=Other&registration%5Bid_number%5D=Waltham&registration%5Bus_citizen%5D=1&registration%5Bopt_in_email%5D=1&registration%5Bopt_in_sms%5D=0&registration%5Bphone%5D=123-456-7890&registration%5Bphone_type%5D=Home

Depending on the host you're testing, you may also need to open Advanced Settings in the Test Settings section and set the 
username and password under Basic authentication.