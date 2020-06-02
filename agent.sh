#!/bin/bash


echo "Agent started..."

UserDir=/home/user1

read -p "Enter Desired Hostname: " ComputerName
echo "Your computer name is: $ComputerName!"

echo "Stopping and disabling firewalld"
systemctl stop firewalld
systemctl disable firewalld

echo "Running yum update"
#yum update
yum check-update

echo "Running yum install for sysadmin tools"
#this command will work for interactive sessions but it's likely that " /usr/bin/apt-get -qq --no-upgrade" will need to be used for when we progress to being run by cron
yum -y install tmux nano sudo

echo "Installing public keys"
mkdir /root/.ssh/
chmod 700 /root/.ssh/
cp ./authorized_keys /root/.ssh/
cp ./authorized_keys $UserDir/.ssh/


echo "setting up Sudo to run without requiring a password"
mkdir ./ORIGINAL
cp /etc/sudoers ./ORIGINAL/
cp ./sudoers /etc/sudoers
echo "Please test and see if Sudo without a password works."
echo "sudo nano hi.txt"

echo "Agent completed running."

