#!/bin/bash

echo "Checking requirements..."

if [ -z "${{secrets.GIT_USERNAME}}" ]; then
	echo "ERROR: GIT user name secret not found, please set the GIT_USERNAME secret for this repo."
	exit 1
fi

if [ -z "${{secrets.GIT_EMAIL}}" ]; then
	echo "ERROR: GIT e-mail secret not found, please set the GIT_EMAIL secret for this repo."
	exit 1
fi


echo "Retrieving current WordPress version from wordpress.org..."
wget http://api.wordpress.org/core/stable-check/1.0/ -O stable.check.txt

tail -n 2 stable.check.txt > stable.tail.txt
head -n 1 stable.tail.txt > stable.txt
sed -i 's/ : "latest"//' stable.txt
sed -i 's/["\t\s]//g' stable.txt
sed -i 's/\([0-9]*\)\.\([0-9]*\)\.[0-9]*/\1.\2/' stable.txt

WP_VERSION=$(<stable.txt)

rm stable*.txt

if [ -z "$WP_VERSION" ]; then
	echo "ERROR: Could not retrieve current WordPress version from wordpress.org."
	exit 1
fi

echo "Current WordPress version is: $WP_VERSION"

README_VERSION=`grep "^Tested up to: $WP_VERSION" ${GITHUB_WORKSPACE}/readme.txt`

if [ ! -z "$WP_VERSION" ]; then
	echo "Readme.txt is up to date... nothing to do."
#	exit 0
fi

echo "Updating readme.txt..."
sed -i "s/^Tested up to: .*/Tested up to: $WP_VERSION/" ${GITHUB_WORKSPACE}/readme.txt

head -n 10 ${GITHUB_WORKSPACE}/readme.txt

echo "Commiting changes to GIT..."
git config --global user.name '${{secrets.GIT_USERNAME}}'
git config --global user.email '${{secrets.GIT_EMAIL}}'
git commit -am "Update Tested up to value in readme.txt"
git push

echo "Updating tag..."
git tag -f 1.0
git push --force origin 1.0

VERSION="${GITHUB_REF#refs/tags/}"
VERSION="${VERSION#v}"

echo "VERSION: $VERSION"

php --version