# Rocky production notes

The application runs on two roles of server: :app and :util.  :app (hood) is the web front end, and :util (rainier) is the back end which runs daemons.  :util is also the place PDFs are generated and served from.  Both servers .bashrc sets RAILS_ENV to production so scripts run in the right environment by default.

## Clean Start

The application includes a set of bootstrap data that will let it get going.  WARNING: running the bootstrap process will reset the partners and state data in the application.  To bootstrap, run:

    $ rake db:bootstrap

There is no rake task to reset the registrant data.  If you want to do that, drop into mysql and truncate the registrants table.  You probably want to do this before going live to clear out any bogus test data.

## Importing State Data

The application is set up to import updates to state-specific data.  You'll want to do this once before launching, then whenever changes are necessary.  You can do this by updating the states.yml file in your repository and by doing a full deploy.


## Cron

There are two cron jobs running on the utility server. One redacts sensitive data from abandoned registrations and the other removes old pdfs from the file system after 15 days. (Or however many days is indicated in the configuration)

    */10 * * * * cd /var/www/register.rockthevote.com/rocky/current && rake -s utility:timeout_stale_registrations RAILS_ENV=[ENV]
    */5  * * * * cd /var/www/register.rockthevote.com/rocky/current && rake -s utility:remove_buckets RAILS_ENV=[ENV]

## Utility Daemons

There are two worker daemons running on the utility server.  They can be managed locally with control scripts or remotely with capistrano.

    $ script/rocky_runner start
    $ script/rocky_runner stop
    $ script/rocky_pdf_runner start
    $ script/rocky_pdf_runner stop

    $ cap deploy:run_workers    # start/restart both workers
    
The deploy:run_workers task also runs during a full deploy

### `rocky_runner`

The `rocky_runner` daemon pulls jobs out of the delayed job queue and runs them.  There are two kinds of jobs: completing a registration and sending a reminder email.  Completing the registration includes generating the PDF, which uses the second daemon to do that work.

### `rocky_pdf_runner`

It would be nice to have both daemons merged into one process, but it was faster to set things up this way.  In the future, using JRuby would let someone do that.  For now, we use the second daemon to avoid paying the cost of launching a Java VM for every PDF merger.

## API configuration
TODO

For API registration call to work correctly PDF_HOST_NAME constant (see config/environments/<env>.rb) should be set to the host name of the server that has to be put in the PDF URLs.

## Email
TODO

Email to registrants is sent by worker daemons running on the :util server.  Email to partners for e.g. password reset is sent from the :app server.

## Server Monitoring

The application is configured with basic monitoring.  NewRelic RPM for performance, and Airbrake for exception monitoring.  New developers can be added to those accounts to get access and email updates.

## Secrets
TODO
* .env.[environmentname] (what goes in here)


The application code repository does not include files that contain sensitive information such as passwords or account keys.  Those files live in the shared/config directory and are symlinked from the release.  When deploying to a new server, those files must be copied over manually.

    config/database.yml
    config/newrelic.yml
    config/initializers/hoptoad.rb

## Deploying production updates

When your code changes are pushed to git origin/master, run

    $ cap [environment_name] deploy

To deploy a specific tag or commit (highly recommended):

    $ cap [environment_name] deploy -Srev=<commit-hash|tag|branch>

# On development and testing

The cucumber feature that exercises the PDF Merge will run either in-process, or with the daemon.  If the daemon is running, it will use that.  If the daemon is not running, it will shell out to java to run the merge directly.

Run the rspec test suite:

    $ bundle exec rspec spec/

Run the features with cucumber:

    $ bundle exec cucumber


TODO:
To get set up for development, run `sudo geminstaller`, which will install all the ruby gems needed by the application.


## Additional Notes

TODO

* reset-admin-pass
ssh rocky@rtvstaging2-web.osuosl.org "cd /var/www/register.rockthevote.com/rocky/current && RAILS_ENV=staging2 bundle exec rake admin:reset_password" | grep "password"
