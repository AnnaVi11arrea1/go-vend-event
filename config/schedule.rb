# Use this file to easily define all of your cron jobs.

set :output, "log/cron_log.log"
set :environment, "production"
env :RAILS_MASTER_KEY, ENV['RAILS_MASTER_KEY'] 

# First day of every month at 03:00 server time.
every "0 3 1 * *" do
  rake "scraper:monthly"
end
