#!/bin/bash
#Agent is a Linux Customization App, designed to efficiently assist with the setup and maintenance of new machines.
echo "Agent started..."

#static:003zz19f40zzb1fac454f95e242

BailOut() {
echo "BailOut: FATAL ERROR!"
echo "BailOut: $1"
echo "BailOut: Script exiting!"
exit #exit entire script
} #End BailOut
  
CheckForAgentUpdatesViaGit() {
#this function checks for script updates via git
#ASSUMPTION: whatever program we are in was something we got via git, and thus that we are in a git repository
#ASSUMPTION: That the commands within can be ran without any user-interaction.  i.e. that the git repository either requires no authentication or that the administrator has handled this already for us so we can run without interaction
echo " Checking for script update via git..."

#pull the newest code.  the repository should be public over https without any authentication required
    #this is similar to gull pull but more careful since we check for merge conflicts and uncommited changes in our local tree
  
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

    echo " Git says we are out-dated."
    echo " Trying to upgrade via git..."
    git merge --ff-only
    #process return code to see if there are merge conflicts.  Return code will be 0 if git pull is successful.
    if [ "$?" = "0" ]; then
    echo " No git errors detected during our upgrade..."
    echo " Launching updated copy of script..."
    $0 #launch updated copy of script
    exit #abort older parent process
    else
    BailOut " You have merge conflicts!  Fix these!"
    fi
} #end CheckForAgentUpdates

#do something fancy that hopefully works
CheckForAgentUpdatesViaGit

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

