# Runs important schedules.
# See more: https://github.com/javan/whenever

every 15.minutes do
  runner 'PostLog.get_statuses', environment: "development"
end
