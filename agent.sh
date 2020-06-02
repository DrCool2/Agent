#!/bin/bash


echo "Agent started..."

UserDir=/home/user1

echo "Stopping and disabling firewalld"
systemctl stop firewalld
systemctl disable firewalld

echo "Running apt update"
apt update

echo "Running apt install for sysadmin tools"
#this command will work for interactive sessions but it's likely that " /usr/bin/apt-get -qq --no-upgrade" will need to be used for when we progress to being run by cron
apt-get -y install tmux nano sudo

echo "Installing public keys"
cp ./authorized_keys /root/.ssh/
cp ./authorized_keys $UserDir/.ssh/

echo "Agent completed running."

