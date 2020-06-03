#!/bin/bash
#Agent is a Linux Customization App, designed to efficiently assist with the setup and maintenance of new machines.
echo "Agent started..."

#static:005zz19f40zzb1fac454f95e242

BailOut() {
echo "BailOut: FATAL ERROR!"
echo "BailOut: $1"
echo "BailOut: Script exiting!"
exit #exit entire script
} #End BailOut
  
GitUpdate() {
#PURPOSE: this function checks for script updates via git.  It then performs an update via git and launches the new copy of the calling script.  this is vaguely similar to gull pull but more careful since we check for merge conflicts and uncommited changes in our local tree
#ASSUMPTION: whatever program we are in was something we got via git, and thus that we are in a git repository
#ASSUMPTION: That the commands within can be ran without any user-interaction.  i.e. that the git repository either requires no authentication or that the administrator has handled this already for us so we can run without interaction
echo " Checking for script update via git..."
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
        echo " Completed checking for script update via git..."
        return #run rest of program
        fi

#sanity checks complete, attempting to upgrade
    echo " Git says we are out-dated."
    echo " Trying to upgrade via git..."
    git merge --ff-only  #a git pull that doesn't do merge conflicts
    #process return code to see if there are merge conflicts.  Return code will be 0 if "git pull" is successful.  there shouldn't be merge conflicts since we already checked to make sure the working directory was clean...but...
    if [ "$?" = "0" ]; then
    echo " No git errors detected during our upgrade..."
    echo " Launching updated copy of script..."
    $0 #launch updated copy of script
    exit #abort this older copy
    else
    BailOut " You have merge conflicts!  Fix these!"
    fi
} #end GitUpdate

#auto update
GitUpdate

echo "Main program begin..."
exit

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

