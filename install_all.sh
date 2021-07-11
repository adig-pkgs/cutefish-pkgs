#!/bin/sh

set -x

for package in $(ls)
do
	if [ -d "$package" ]; then
		cd "$package"
		# Skip failed packages, go on to install/update other packages of the group
		makepkg -si --noconfirm --needed || true
		cd ..
	fi
done
