#!/bin/bash

echo "starting ssh setup"

echo "creating ~/.ssh"
mkdir ~/.ssh

echo "copying authorized_keys to ~/.ssh/authorized_keys"
cp ~/Agent/authorized_keys ~/.ssh/authorized_keys

echo "updating permissions to 644 ~/.ss/authorized_keys"
chmod 644 ~/.ssh/authorized_keys

echo "updating permissions to 700 for ~/.ssh"
chmod 700 ~/.ssh

echo "checking work - ~/.ssh folder permissions should be 700"
ls -lah ~/ | grep .ssh

echo "checking work - ~/.ssh/authorized_keys permissions should be 644"
ls -lah ~/.ssh | grep authorized_keys

echo "finishing ssh setup"
