# Use this file to easily define all of your cron jobs.

set :output, "log/cron_log.log"
set :environment, 'production'

every 2.weeks do
  rake "scraper:all"
end
