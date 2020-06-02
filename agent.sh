#!/bin/bash


echo "Agent started..."

UserDir=/home/user1

read -p "Enter Desired Hostname: " ComputerName
echo "Your computer name is: $ComputerName!"
#read -s -p "Enter Root Password: " RootPassword

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
if [[ -d "/root/.ssh" ]]
then
 sudo rm -r /root/.ssh/
fi
  mkdir /root/.ssh/
  chmod 700 /root/.ssh/
  cp ./authorized_keys /root/.ssh/

if [[ -d "$UserDir/.ssh"  ]]
then
  rm -r $UserDir/.ssh
fi
  mkdir $UserDir/.ssh
  chown user1 $UserDir/.ssh
  chmod 700 $UserDir/.ssh
  cp ./authorized_keys $UserDir/.ssh/


echo "setting up Sudo to run without requiring a password"
if [[ ! -d ./ORIGINAL  ]]
then
echo "./ORIGINAL does NOT exist. Creating it now..."
mkdir ./ORIGINAL
cp /etc/sudoers ./ORIGINAL/
cp ./sudoers /etc/sudoers
fi

exit

echo "Agent completed running."

