#!/bin/bash
#Agent is a Linux Customization App, designed to efficiently assist with the setup and maintenance of new machines.
echo "Agent started..."

echo "Stopping and disabling firewalld"
systemctl stop firewalld
systemctl disable firewalld

echo "Running yum check-update"
yum check-update  #I don't think those words mean what you think they mean

echo "Running yum install for sysadmin tools"
#this command will work for interactive sessions but it's likely that " /usr/bin/apt-get -qq --no-upgrade" will need to be used for when we progress to being run by cron
yum -y install tmux nano sudo

echo "Installing public keys"
mkdir /root/.ssh/
chmod 700 /root/.ssh/
cp ./authorized_keys /root/.ssh/
cp ./authorized_keys $UserDir/.ssh/


#echo "setting up Sudo to run without requiring a password"
#mkdir ./ORIGINAL
#cp /etc/sudoers ./ORIGINAL/
#cp ./sudoers /etc/sudoers


echo "Agent completed running."

