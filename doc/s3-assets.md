# Storing assets on Amazon S3

All files from app/assets are stored on Amazon S3 for faster serving and
to minimize the number of connections with the app.

Assets are pre-compiled by the assets pipeline during the deployment and
automatically sync'ed with the Amazon S3 bucket so that the new files
are uploaded, the changed are updated and the ones that aren't being
used any more are deleted. There are no extra steps involved in moving
pre-compiled assets to the bucket.

The app is configured to use the named bucket as an asset host and will
request images / css / javascript files automatically from it if the
asset pipeline helper methods are used -- image_url (in CSS), image_tag
(in ERB) etc. For more details on the methods refer to the [Assets
pipeline guide](http://guides.rubyonrails.org/v3.2.18/asset_pipeline.html).


## Deployment configuration

All configuration is performed via environment variables, that must be
set in an environment-specific `.env` file (see `.env.ENVNAME.example`
for an example).

  * FOG_PROVIDER -- provider to use for assets storage (always 'AWS')
  * AWS_ACCESS_KEY_ID -- AWS user access key (from AWS Credentials)
  * AWS_SECRET_ACCESS_KEY -- AWS secret access key (from AWS Credentials)
  * FOG_DIRECTORY -- name of AWS bucket (avoid periods in the name)

