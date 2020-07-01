#!/bin/bash
#Agent is a Linux Customization App, designed to efficiently assist with the setup and maintenance of new machines.
echo "Agent started..."

echo "----------" >> /var/log/agent.log
echo "agent.sh started at: "$(date) >> /var/log/agent.log

BailOut() {
echo "BailOut: FATAL ERROR!"
echo "BailOut: $1"
echo "BailOut: Script exiting!"
exit #exit entire script
} #End BailOut
  
GitUpdate() {
: <<'END_COMMENT_BLOCK'  #this is a comment block
    #Purpose: checks for script updates via git.  It then performs an update via git and launches the new copy of the calling script.  this is vaguely similar to gull pull but more careful since we check for merge conflicts and uncommited changes in our local tree

    #Usage Example:
    echo "Script starting up!"
    GitUpdate
    echo "More scripty stuff."

    Note:
    #ASSUMPTION: whatever program we are in was something we got via git, and thus that we are in a git repository
    #ASSUMPTION: That the commands within can be ran without any user-interaction.  i.e. that the git repository either requires no authentication or that the administrator has handled this already for us so we can run without interaction

END_COMMENT_BLOCK
echo " GitUpdate Begin."

if [ "$GitUpdateDisabled" = "true" ]; then
#This toggle is available for development or debugging purposes.  It will skip GitUpdate.
#to use the toggle, set the following variable in your bash session with 'export' before running this script:
#export GitUpdateDisabled=true
echo "GitUpdateDisabled=true, skipping GitUpdate"
return
fi

#cd to calling script directory so we can run git commands
local SCRIPTDIR="$( cd "$(dirname "$0")" ; pwd -P )"   #directory this script is in
cd $SCRIPTDIR  #gotta cd (in case someone ran us like "cd /tmp;/root/script.sh") so later git commands will be in the repository we are in
unset SCRIPTDIR #our time together was so short

#local git repo sanity checks.  let's not make ANY assumptions here
    #do we have unpushed commits?
    git status | grep "Your branch is ahead of"
        if [ "$?" = "0" ]; then
        BailOut " Git says we have unpushed commits.  Please discard these or push them."
        else
        echo " Git says our branch has no unpushed commits."
        fi

    #is our working tree clean?
    git status | grep "nothing to commit, working tree clean"
        #check return code to see if our working tree is clean with no local modifications
        if [ "$?" = "0" ]; then
        echo " Git says our working tree is clean, so we can try updating..."
        else
        BailOut "Git says our working tree is not clean.  Run git status for more info."
        fi

    #ok, our working tree is clean, but are we already up to date?
    #check repo
    git fetch
    git status | grep "Your branch is up to date"
        #check return code to see if we are up to date
        if [ "$?" = "0" ]; then
        echo " Git says we are already up to date..."
        #no further action needed, we can just run what we have locally since it's up to date
        echo " GitUpdate End."
        return #run rest of program
        fi

#local repo sanity checks complete, attempting to upgrade
    echo " Git says we are out-dated."
    echo " Trying to upgrade via git..."
    git merge --ff-only  #a git pull that doesn't do merges, so won't create merge conflicts
    #process return code to see if there are merge conflicts.  Return code will be 0 if "git pull" is successful.  there shouldn't be merge conflicts since we already checked to make sure the working directory was clean...but...
    if [ "$?" = "0" ]; then
    echo " No git errors detected during our upgrade..."
    echo " Launching updated copy of script..."
    echo " GitUpdate End."
    $0 #launch updated copy of script
    exit #abort this older copy
    else
    BailOut " You have merge conflicts!  Fix these!"
    fi
} #end GitUpdate

#auto update
GitUpdate

echo "Main program begin..."

UserDir=/home/user1
RestartNeeded="N"

echo "Checking Crontab to see if Agent settings have already been applied."
if [[ $(crontab -l | grep -c "agent.sh") > 1 ]]; then
echo "crontab -l does contain: agent.sh"
else
echo "crontab -l does NOT contain: agent.sh"
echo "adding entry to crontab: 00 * * * * /usr/local/sbin/Agent/agent.sh"

# source https://stackoverflow.com/questions/878600/how-to-create-a-cron-job-using-bash-automatically-without-the-interactive-editor
# author: MoonCactus
# date and time accessed: 6-30-2020 12:31pm
croncmd="/usr/local/sbin/Agent/agent.sh"
cronjob="00 * * * * $croncmd"
( crontab -l | grep -v -F $croncmd ; echo $cronjob ) | crontab -

# adding entry to log file
echo "crontab: $(crontab -l | grep agent.sh)" >> /var/log/agent.log
fi

# test Hostname to see if it needs to be changed from Default
current_hostname=$(hostname)
default_hostname="localhost.localdomain"
if [[ $current_hostname = $default_hostname ]]
then
  echo "Your Hostname is the Default: $(hostname)"
  read -p "Enter Desired Hostname: " ComputerName

  if [[ -z $ComputerName ]]
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
if [[ $user_exists = 1 ]]
then
  echo "User1 does NOT exist!!!"
  echo "Creating User1 Account."
  useradd -m User1
  echo "Please enter User1's Password: " | passwd --stdin User1
  RestartNeeded="Y"
fi

#chmod 700 /etc/sudoers
#rm /etc/sudoers
#cp .sudoers /etc/sudoers
##chown root /etc/sudoers
#chmod 440 /etc/sudoers


echo "Stopping and disabling firewalld"
systemctl stop firewalld
systemctl disable firewalld

echo "Running NodeJS installer for Rails and Webpacker:Install to work."
# installs YARN for Ruby on Rails, rails webpacker:install to work
curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo

echo "Running yum install for sysadmin tools"
#this command will work for interactive sessions but it's likely that " /usr/bin/apt-get -qq --no-upgrade" will need to be used for when we progress to being run by cron
yum -y install tmux nano sudo gnupg nodejs yarn

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

echo "refreshing DNS Servers using NetworkManager.service"
sudo systemctl restart NetworkManager.service

echo
echo "current DNS servers are: "
sudo nmcli | grep DNS -A 3
echo "DNS Servers: "$(sudo nmcli | grep DNS -A 3)
echo

echo "agent.sh ended at: "$(date) >> /var/log/agent.log
echo "----------" >> /var/log/agent.log

if [[ $RestartNeeded = "Y" ]]
then
  echo "Agent completed running."
  echo "Restarting System due to configuration change..."
  sleep 3s
  shutdown -r
else
  echo "Agent completed running."
fi
