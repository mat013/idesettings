#!/bin/bash

# Inspired by https://chrisseroka.wordpress.com/2017/12/07/cleaning-up-git-branches/

echo fetching all
git fetch --all --prune

echo Fetching branch with missing remotes
git branch -vv | grep ": gone\]" > .to-remove && vim .to-remove
cat .to-remove

read -p 'Continue? Yes if you want to continue: '

if [[ $REPLY == 'Yes' ]];
then
  grep ".*" .to-remove | cut -c 3- | awk '{print $1}' | xargs git branch -D
fi
