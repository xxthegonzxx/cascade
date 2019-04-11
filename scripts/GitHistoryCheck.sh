#!/bin/bash

#This script will grab both the git logs of the requested branches and compare to ensure the entirety of one is within the other ( and therefore all of the git log metadata is preserved.) 
echo
echo working ...
echo
#grab currentBranch's name and save it,
CURRENTBRANCH=$(git rev-parse --abbrev-ref HEAD)
#Ensure that arg[1] isn't malicious and the branch actually exists on origin
if (git branch -a | grep -w -q $1); then 
    INTOBRANCH=$1 
else 
  echo Error Branch $1 Does Not Exist. Please pass a valid branch that exists on origin as a your parameter e.g. "dev"
  exit 1
fi
#grab all IntoBranch's git log data from origin and save it to a parsable object.
git log origin/$INTOBRANCH --pretty=%H > destination_branch.txt
git log $CURRENTBRANCH --pretty=%H > current_branch.txt
if [[ $(comm -2 -3 <(sort ./destination_branch.txt) <(sort ./current_branch.txt)) ]]; then
  echo "Problem Found"
  echo "The following commits were not found in your destination branch"
  echo $(comm -2 -3 <(sort ./destination_branch.txt) <(sort ./current_branch.txt))
  exit 1
else
  echo "All commits match with Destination Branch"
fi