#!/bin/bash

echo "Retrieving current WordPress version from wordpress.org..."
wget http://api.wordpress.org/core/stable-check/1.0/ -O stable.check.txt

tail -n 2 stable.check.txt > stable.tail.txt
head -n 1 stable.tail.txt > stable.txt
sed -i 's/ : "latest"//' stable.txt
sed -i 's/["\t\s]//g' stable.txt

WP_VERSION=$(<stable.txt)

rm stable*.txt

if [ -z "$WP_VERSION" ]; then
	echo "ERROR: Could not retrieve current WordPress version from wordpress.org."
else
	echo "Current WordPress version is: $WP_VERSION"

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
fi