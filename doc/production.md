# Rocky production notes

The application runs on two roles of server: :app and :util.  :app (hood) is the web front end, and :util (rainier) is the back end which runs daemons.  :util is also the place PDFs are generated and served from.  Both servers .bashrc sets RAILS_ENV to production so scripts run in the right environment by default.

## Clean Start

The application includes a set of bootstrap data that will let it get going.  WARNING: running the bootstrap process will reset the partners and state data in the application.  To bootstrap, run:

    $ rake db:bootstrap

There is no rake task to reset the registrant data.  If you want to do that, drop into mysql and truncate the registrants table.  You probably want to do this before going live to clear out any bogus test data.

## Importing State Data

The application is set up to import updates to state-specific data.  You'll want to do this once before launching, then whenever changes are necessary.  You can do this with rake on the server, but it's easier to use cap on your local machine.

    $ cap import:states CSV_FILE=/path/to/state.csv

The cap task will upload and import the data, then restart the app server so that state data cached in memory is reloaded.

## Cron

There are two cron jobs running on the utility server. One redacts sensitive data from abandoned registrations and the other removes old pdfs from the file system after 15 days.

    */10 * * * * cd /var/www/register.rockthevote.com/rocky/current && rake -s utility:timeout_stale_registrations RAILS_ENV=production
    */5  * * * * rocky RAILS_ENV=production /var/www/register.rockthevote.com/rocky/current/lib/bucket_remover.rb

## Utility Daemons

There are two worker daemons running on the utility server.  They can be managed locally with control scripts or remotely with capistrano.

    $ script/rocky_runner start
    $ script/rocky_runner stop
    $ script/rocky_pdf_runner start
    $ script/rocky_pdf_runner stop
    
    $ cap deploy:run_workers    # start/restart both workers

### `rocky_worker`

The `rocky_worker` daemon pulls jobs out of the delayed job queue and runs them.  There are two kinds of jobs: completing a registration and sending a reminder email.  Completing the registration includes generating the PDF, which uses the second daemon to do that work.

### `rocky_pdf_worker`

It would be nice to have both daemons merged into one process, but it was faster to set things up this way.  In the future, using JRuby would let someone do that.  For now, we use the second daemon to avoid paying the cost of launching a Java VM for every PDF merger.

## Email

Email to registrants is sent by worker daemons running on the :util server.  Email to partners for e.g. password reset is sent from the :app server.

## Server Monitoring

The application is configured with basic monitoring.  NewRelic RPM for performance, and HopToad for exception monitoring.  New developers can be added to those accounts to get access and email updates.

## Secrets

The application code repository does not include files that contain sensitive information such as passwords or account keys.  Those files live in the shared/config directory and are symlinked from the release.  When deploying to a new server, those files must be copied over manually.

    config/database.yml
    config/newrelic.yml
    config/initializers/hoptoad.rb

## Deploying production updates

When your code changes are pushed to git origin/master, run

    $ cap deploy

To deploy a specific tag or commit (highly recommended):

    $ cap deploy -Srev=<commit-hash|tag|branch>

# On development and testing

The cucumber feature that exercises the PDF Merge will run either in-process, or with the daemon.  If the daemon is running, it will use that.  If the daemon is not running, it will shell out to java to run the merge directly.

Run the rspec test suite:

    $ rake

Run the webrat features with cucumber:

    $ rake features

Run the selenium features with cucumber:

    $ rake features:selenium

Run all the non-selenium stuff:

    $ rake default features

To get set up for development, run `sudo geminstaller`, which will install all the ruby gems needed by the application.
