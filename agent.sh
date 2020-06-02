#!/bin/bash


#echo "Agent started..."


# SOURCE: https://stackoverflow.com/questions/323957/how-do-i-edit-etc-sudoers-from-a-script
#if [ -z "$1" ]; then

  # When you run the script, you will run this block since $1 is empty.

#  echo "Starting up visudo with this script as first parameter"

  # We first set this script as the EDITOR and then starts visudo.
  # Visudo will now start and use THIS SCRIPT as its editor
#  export EDITOR=$0 && sudo -E visudo
#else

  # When visudo starts this script, it will provide the name of the sudoers
  # file as the first parameter and $1 will be non-empty. Because of that,
  # visudo will run this block.

#  echo "Changing sudoers"

  # We change the sudoers file and then exit
#  echo "# adding USER1 to SUDOERS file with NO PASSWORD ENTRY REQUIRED. " >> $1
#  echo "user1 ALL=(ALL:ALL) NOPASSWD: ALL" >> $1
#fi


echo "Agent started..."

UserDir=/home/user1

read -p "Enter Desired Hostname: " ComputerName
echo "Your computer name is: $ComputerName!"
#read -s -p "Enter Root Password: " RootPassword

if [[ -d "~/BACKUP"  ]]
then
cp /etc/sudoers ~/BACKUP/
else
mkdir ~/BACKUP
cp /etc/sudoers ~/BACKUP/
fi

cp .sudoers /etc/sudoers
chown root /etc/sudoers


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


# Checking to see if ORIGINAL folder exists.
if [[ ! -d ./ORIGINAL  ]]
then
    echo "./ORIGINAL does NOT exist. Creating it now..."
    mkdir ./ORIGINAL
    cp /ect/sudoers ./ORIGINAL/sudoers-date +"%m_%d_%Y"
fi

echo "Agent completed running."

