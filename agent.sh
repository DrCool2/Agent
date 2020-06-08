#!/bin/bash


echo "Agent started..."

UserDir=/home/user1

read -p "Enter Desired Hostname: " ComputerName
if [ -z $ComputerName ]
then
  ComputerName=$(hostname)
  echo "Your current computer name is: "$ComputerName"!"
  sleep 1s
else
  echo "Your computer name is: "$ComputerName!"!"
fi

#chmod 700 /etc/sudoers
#rm /etc/sudoers
#cp .sudoers /etc/sudoers
##chown root /etc/sudoers
#chmod 440 /etc/sudoers


echo "Stopping and disabling firewalld"
systemctl stop firewalld
systemctl disable firewalld

echo "Running yum install for sysadmin tools"
#this command will work for interactive sessions but it's likely that " /usr/bin/apt-get -qq --no-upgrade" will need to be used for when we progress to being run by cron
yum -y install tmux nano sudo gnupg

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


# Checking to see if ORIGINAL folder exists.
if [[ ! -d ./ORIGINAL  ]]
then
    echo "./ORIGINAL does NOT exist. Creating it now..."
    mkdir ./ORIGINAL
    cp /ect/sudoers ./ORIGINAL/sudoers-date +"%m_%d_%Y"
fi


echo "Installing Ruby on Rails lastest"
#gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
gpg2 --refresh-keys
curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -

\curl -sSL https://get.rvm.io | bash -s stable --rails
source /usr/local/rvm/scripts/rvm

ruby -v
rails -v
sleep 3s

echo "Agent completed running."

