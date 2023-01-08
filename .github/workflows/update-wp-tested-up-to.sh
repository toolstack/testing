#!/bin/bash

set
exit 0

echo "Checking requirements..."

if [ -z "$GIT_USERNAME" ]; then
	echo "ERROR: GIT user name secret not found, please set the GIT_USERNAME secret for this repo."
	exit 1
fi

if [ -z "$GIT_EMAIL" ]; then
	echo "ERROR: GIT e-mail secret not found, please set the GIT_EMAIL secret for this repo."
	exit 1
fi

echo "Configuring GIT..."
git config --global user.name '$GIT_USERNAME'
git config --global user.email '$GIT_EMAIL'

echo "Getting the latest tag name..."
# This will get us the latest tag in the repo.
git tag > tag.txt

cat tag.txt

# Strip out the preceeding "refs/tags/" text from it.
#sed -i 's/refs\/tags\///' tag.txt

# Store it in a variable and delete the temp file.
TAG=$(<tag.txt)
rm tag.txt

if [ -z "$TAG" ]; then
	echo "ERROR: Could not retrieve current tag from GIT."
	exit 1
fi

echo "Current tag is: $TAG"

echo "Retrieving current WordPress version from wordpress.org..."
wget http://api.wordpress.org/core/stable-check/1.0/ -O stable.check.txt

# Get the second last line of the file.
tail -n 2 stable.check.txt > stable.tail.txt
head -n 1 stable.tail.txt > stable.txt

# Strip out the status.
sed -i 's/ : "latest"//' stable.txt

# Get rid of the quotes, tabs, and spaces.
sed -i 's/["\t\s]//g' stable.txt

# Now cut down any 3 part versions, like 6.1.1, to two parts, aka 6.1.
sed -i 's/\([0-9]*\)\.\([0-9]*\)\.[0-9]*/\1.\2/' stable.txt

# Store it in a variable and delete the temp files.
WP_VERSION=$(<stable.txt)
rm stable*.txt

if [ -z "$WP_VERSION" ]; then
	echo "ERROR: Could not retrieve current WordPress version from wordpress.org."
	exit 1
fi

echo "Current WordPress version is: $WP_VERSION"

# Do a grep on the readme.txt file to see if the values already set correctly.
README_VERSION=`grep "^Tested up to: $WP_VERSION" ${GITHUB_WORKSPACE}/readme.txt`
README_TAG=`grep "^Stable tag: $TAG" ${GITHUB_WORKSPACE}/readme.txt`

# Grep will return any matching string, so if we add both of the above together and
# check to see if we have an empty string, that will tell us if we have updates to do
# or not.
if [ ! -z "$README_VERSION" && ! -z "$README_TAG" ]; then
	echo "Readme.txt is up to date... nothing to do."
	exit 0
fi

# Replace the strings in the readme.txt.
echo "Updating readme.txt..."
sed -i "s/^Tested up to: .*/Tested up to: $WP_VERSION/" ${GITHUB_WORKSPACE}/readme.txt
sed -i "s/^Stable tag: .*/Stable tag: $TAG/" ${GITHUB_WORKSPACE}/readme.txt

# Display out the first 10 lines of the new readme.txt for logging.
head -n 10 ${GITHUB_WORKSPACE}/readme.txt

echo "Commiting changes to GIT..."
git commit -am "Update Tested up to value in readme.txt"
git push

echo "Updating tag..."
git tag -f $TAG
git push --force origin $TAG1
