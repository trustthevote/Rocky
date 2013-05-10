Administrative Interface
========================

Credentials
-----------

* Default username is `admin` and is set in `config/settings.yml` as
  `admin_username`.

* Default password is not set (admin login isn't possible). To reset the
  password use rake task:

      $ bundle exec rake admin:reset_password

