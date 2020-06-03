#!/bin/bash
#Agent is a Linux Customization App, designed to efficiently assist with the setup and maintenance of new machines.
echo "Agent started..."

#static:bb19f409b1fac454f95e242a5

BailOut() {
echo "BailOut: FATAL ERROR!"
echo "BailOut: $1"
echo "BailOut: Script exiting!"
exit #exit entire script
} #End BailOut
  
CheckForAgentUpdates() {
#this function checks for agent updates via git
#ASSUMPTION: whatever program we are in was something we got via git, and thus that we are in a git repository
#ASSUMPTION: That the commands within can be ran without any user-interaction.  i.e. that the git repository either requires no authentication or that the administrator has handled this already for us so we can run without interaction
echo "Checking for agent update via git..."

#pull the newest code.  the repository should be public over https without any authentication required
    #this is similar to gull pull but more careful since we check for merge conflicts
    #check repo
    git fetch
    #are we already up to date?
    git status | grep "Your branch is up to date"
        #check return code to see if we are up to date
        if [ "$?" = "0" ]; then
        echo "Git says we are already up to date..."
        #no further action needed, we can just run what we have locally since it's up to date
        return #run rest of program
        fi
        
        echo "Trying to upgrade via git..."
        git merge --ff-only
        #process return code to see if there are merge conflicts.  Return code will be 0 if git pull is successful.
        if [ "$?" = "0" ]; then
        echo "No git errors detected during our upgrade..."
        echo "Launching updated copy of script..."
        ./agent.sh #launch updated copy of script
        exit #abort older parent process
        else
        BailOut "You have merge conflicts!  Fix these!"
        fi
} #end CheckForAgentUpdates

#do something fancy that hopefully works
CheckForAgentUpdates

echo "main program run";exit
UserDir=/home/user1

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

