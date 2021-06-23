#!/bin/sh

set -x

for package in $(ls)
do
	if [ -d "$package" ]; then
		cd "$package" && makepkg -si && cd ..
	fi
done
