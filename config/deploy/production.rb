role :web, "register.rockthevote.com" #  "rtvprod-web1.osuosl.org"
role :app, "register.rockthevote.com" #  "rtvprod-web1.osuosl.org"
role :util, "rtvprod-util.osuosl.org"
role :db,   "rtvprod-util.osuosl.org", :primary => true
# role :db,   "rtv-db.osuosl.org", :primary => true
set :branch, (rev rescue "production")
