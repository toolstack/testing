#!/bin/bash

echo "Retrieving current WordPress version from wordpress.org..."
wget http://api.wordpress.org/core/stable-check/1.0/ -O stable.check.txt
tail -n 2 stable.check.txt > stable.tail.txt
head -n 1 stable.tail.txt > stable.txt
sed -i 's/ : "latest"//' stable.txt
sed -i 's/["\t\s]//g' stable.txt

WP_VERSION=$(<stable.txt)

rm stable*.txt

echo "Current WordPress version is: $WP_VERSION"