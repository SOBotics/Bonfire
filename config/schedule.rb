# Runs important schedules.
# See more: https://github.com/javan/whenever

every 15.minutes, mailto: 'log@bonfire.sobotics.org'  do
  runner 'PostLog.get_statuses', environment: "development"
end
