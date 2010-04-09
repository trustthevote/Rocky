role :web,  "rtvstaging-web.osuosl.org"
role :app,  "rtvstaging-web.osuosl.org"
role :util, "rtvstaging-util.osuosl.org"
role :db,   "rtvstaging-web.osuosl.org", :primary => true

set :rails_env,    "staging"
