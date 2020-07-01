#!/bin/bash

echo "This script will install everything in the current working directory to a system location and schedule it to run hourly."
echo "It seems safe to try installing the same program multiple times."
echo
echo "You are responsible for:"
echo "-ensuring your script has dependency checking"
echo "-that your script is able to run in a non-interactive environment"
echo
echo "The contents of the current working directory is $PWD which will be copied into /usr/local/sbin/install-cwd/agent/"
sleep 10s  #no need to let the user press enter before they've read the above message :-)
echo "Press <enter> to continue, or control+C to exit."
read
echo
echo "Installing..."
sleep 2s
mkdir -p /usr/local/sbin/install-cwd/agent/
/usr/bin/cp -R -v --force ./. /usr/local/sbin/install-cwd/agent/
echo "Files installed to system location."
sleep 2s
echo "Adding hourly cron launcher."
echo "#!/bin/bash" > /etc/cron.hourly/agent
echo "" >> /etc/cron.hourly/agent
echo "/usr/local/sbin/install-cwd/agent/agent.sh" >> /etc/cron.hourly/agent
chmod +x /etc/cron.hourly/agent
echo "Hourly cron launcher added!"
echo "To verify, wait 61 minutes then run: cat /var/log/cron"
