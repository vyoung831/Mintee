#!/bin/sh

# 
# Script to run before archiving builds of Mu.
# This script checks that the current local branch is tracking from and up-to-date with origin/master.
#

# Get the (upstream:short) format of HEAD
UPSTREAM_NAME=$(git for-each-ref --format="%(upstream:short)" $(git symbolic-ref HEAD))

echo $UPSTREAM_NAME
# Check that repo is tracking with origin/master
if [[ $UPSTREAM_NAME != "origin/master" ]]; then
    exit 1
fi

git fetch

# Fetch and check that local HEAD is in sync with remote master branch
if [[ $(git rev-list -n 1 HEAD) != $(git rev-list -n 1 $UPSTREAM_NAME) ]]; then
    exit 2
fi

# Check that merge conflicts don't exist
if [[ $(test -e ../.git/MERGE_HEAD) ]]; then
    exit 3
fi

# Check that no staged or unstaged changes remain
if [[ $(git --no-pager diff) ]] || [[ $(git --no-pager diff --cached) ]] ; then
    exit 4
fi