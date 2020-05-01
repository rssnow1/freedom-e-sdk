#!/bin/bash
# Copyright (c) 2020 SiFive Inc.
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

if [ "$#" -lt 2 ] ; then
  >&2 echo "$0: please provide project name and release tag"
  exit 1
fi

project=$1; shift 1;
current_release=$1; shift 1;

# Get the most recent tag associated with a full release. This uses the criteria:
#  1. tag starts with a 'v'
#  2. tag does not contain 'rc' or 'RC'
last_full_release=$(git tag --sort=creatordate | grep "^v.*" | grep -Ev "(rc|RC)" | tail -n 1)

# The merge-base is the most-recent commit on the current branch which shares
# common ancestry with the last full release.
merge_base=$(git merge-base ${last_full_release} HEAD)

# Describe the merge-base commit
last_release=$(git describe --tags ${merge_base})

echo "# Release notes for ${project} ${current_release}"
echo "## Statistics since ${last_release}"
echo "- $(git rev-list --count ${last_release}..HEAD) commits"
echo "-$(git diff --shortstat ${last_release} HEAD)"
echo ""
echo "## Authors"
git shortlog -s -n --no-merges ${last_release}..HEAD | cut -f 2
echo ""
echo "## Merge history"
git log --merges --pretty=format:"%h %b" ${last_release}..HEAD
