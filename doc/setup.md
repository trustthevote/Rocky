# Setup Instructions

Rocky consists of two pieces: A base application (rocky), and a rubygem package that contains all the brand-specific content (rocky\_branding). This application will *not* run without first installing a `rocky_branding` gem.  See section 2 below.

Two things you need to do to set up your application after installing the project code.

## 1. Create real versions of the .example files

In the `rocky` application replace all the *.example files with real ones.  These files contain sensitive data like passwords so we don't commit them to version control.  You'll of course need to fill in the actual useful data in the real files.

  * `config/database.yml`
  * `config/newrelic.yml`
  * `config/initializers/hoptoad.rb`
  * `config/initializers/session_store.rb`
  * `db/bootstrap/partners.yml`

## 2. Install and use the branding package gem

You'll need to install a gem that has the branding package contents in it, then link it into the rocky app.

1. Install the branding gem.  You probably have a .gem file locally that you just built (see below), so run `[sudo] gem install rocky_branding-X.Y.Z.gem`
2. cd to the rocky project and run `rake branding:symlink` to symlink the installed gem files into the rocky app.

### About the branding gem

All the brand-specific bits related to a particular sponsor organization have been removed from the main rocky code and moved into a separate rocky\_branding gem.  This makes it pretty easy to manage different brandings and install/deploy them on various servers.

### How to make a new branding gem

1. Clone the rocky\_branding git project to a new project and rename it to something like `sponsor_org_name-rocky_branding`.
2. Get a bunch of files from the sponsor org and put them in the project in their appropriate locations.  Ideally the sponsor org will own all the content and a developer only has to package up the files.
3. Edit the `rocky_branding.gemspec` file to update the version number, description and any other metadata that needs changing.  Don't change the name attribute!  You shouldn't ever need to edit the list of files since they are generated dynamically from a directory glob.
4. In a shell execute `gem build rocky_branding.gemspec`.  That should generate a gem file called `rocky_branding-X.Y.Z.gem`. You might want to rename the gem file to include the name of the sponsor org to avoid confusion, but it's not necessary.
5. Run `[sudo] gem install rocky_branding-X.Y.Z.gem` to install the freshly built gem into your system.
6. cd to the rocky project and run `rake branding:symlink` to symlink the installed gem files into the rocky app.
7. Run the tests in rocky to make sure the new gem works.

NOTE: In an ideal world, the sponsor org will deliver a set of branding files you can dump into gem project.  The biggest pain is when you are doing development and need to change one of the files in the branding package.  You'll need to be careful to keep edits to those files in sync between the rocky\_branding git project and the installed gem files that are symlinked into the rocky app.  It's a bit tedious, but the best way is to edit them in the rocky\_branding project, build the gem, install it, then `rake branding:symlink` to link it in.

### Deploying the branding gem

The branding gem must be installed on the app and util servers for rocky to run at all. It's best to install the branding gem before deploying the app, even for the first time.  Once the app and branding gem are installed, updates are easy.

In the examples below, replace `INSTANCE` with `staging` or `production`.

To upload/install a gem to all the rocky servers, cd to the rocky project and run

    cap INSTANCE deploy:install_branding

That scp's the .gem file to the servers and runs gem install.  It might take a little while.

The capistrano recipes automatically re-link the branding package when the server is redeployed.  If you upload/install a new branding gem, you should manually run

    cap INSTANCE deploy:symlink_branding
    cap INSTANCE deploy:restart

