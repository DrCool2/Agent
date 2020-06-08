#!/bin/bash


echo "Agent started..."

UserDir=/home/user1
RestartNeeded="N"

# test Hostname to see if it needs to be changed from Default
current_hostname = $(hostname)
if [[ $current_hostname="localhost.localdomain" ]]
then
  echo "Your Hostname is the Default: $(hostname)"
  read -p "Enter Desired Hostname: " ComputerName
  
  if [ -z $ComputerName ]
  then
     ComputerName=$(hostname)
     echo "Your current computer name is: "$ComputerName"!"
      sleep 3s
  else
     echo "updating /etc/hostname"
     echo $ComputerName > /etc/hostname
     echo "updating /etc/hosts"
     echo "127.0.0.1  localhost "$ComputerName" localhost4 "$ComputerName > /etc/hosts
     echo "::1  localhost "$ComputerName" localhost6 "$ComputerName >> /etc/hosts
      RestartNeeded="Y"
     echo "Your computer name is: "$ComputerName!"!"
     sleep 3s
  fi
fi

# Create User1 if User1 does not exist, 1 = does NOT exist
user_exists=$(id -u User1 > /dev/null 2>&1; echo $?)
if [$user_exists=0]
then
  echo "User1 does NOT exist!!!"
  echo "Creating User1 Account."
  useradd -m User1
  echo "Please enter User1's Password: " | passwd --stdin User1
  RestartNeeded="Y"
fi

sleep 10s

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

echo "Installing public SSH keys"
if [[ -d "/root/.ssh" ]]
then
  rm -r /root/.ssh/
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
#if [[ ! -d ./ORIGINAL  ]]
#then
#    echo "./ORIGINAL does NOT exist. Creating it now..."
#    mkdir ./ORIGINAL
#    cp /ect/sudoers ./ORIGINAL/sudoers-date +"%m_%d_%Y"
#fi


echo "Installing Ruby on Rails lastest"
#gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
gpg2 --refresh-keys
curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -

\curl -sSL https://get.rvm.io | bash -s stable --rails
# runs the RVM software
source /usr/local/rvm/scripts/rvm

# adds user to RVM group
usermod -a -G rvm user1

ruby -v
rails -v
sleep 3s

if [[ $RestartNeeded="Y" ]]
then
  echo "Agent completed running."
  echo "Restarting System due to configuration change..."
  sleep 3s
  shutdown -r
else
  echo "Agent completed running."
fi
