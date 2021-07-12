#!/bin/bash

# Higly inspired from kaz/archlinux-repository-boilerplate

ARCH=x86_64
MAKEFLAGS="-j$(nproc)"

: ${BUILD_USER:="builder"}

: ${PKGS_DIR=/tmp/__pkgs__}
: ${CCACHE_DIR:="/tmp/ccache"}

: ${GITHUB_ACTOR:=""}
: ${GIT_REMOTE:=""}
: ${GIT_BRANCH:="gh-pages"}

GITHUB_REPO_OWNER=${GITHUB_REPOSITORY%/*}
ARCH_REPO_NAME=cutefish-git

initialize() {
	pacman -Syu --noconfirm --needed git ccache ninja

	echo "${BUILD_USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${BUILD_USER}
	echo "cache_dir = ${CCACHE_DIR}" > /etc/ccache.conf

	useradd -m ${BUILD_USER}
	chown -R ${BUILD_USER}:${BUILD_USER} .
}

build() {
	export MAKEFLAGS="-j$(nproc)"

	mkdir -pv "${PKGS_DIR}"

	for PKGBUILD_PATH in $(find . -name "PKGBUILD"); do
		pkgbuild_dir=${PKGBUILD_PATH%PKGBUILD}
		pushd "$pkgbuild_dir"
			sudo -u "${BUILD_USER}" makepkg -sr --noconfirm --needed
			cp -v *.pkg.tar.zst "${PKGS_DIR}/"
		popd
	done
}

publish() {
	# Expecting the branch is cloned at "${GITHUB_BRANCH}"
	cd "$GIT_BRANCH"
 	# git checkout "${GIT_BRANCH}"
	rm -rfv "${ARCH}"
	mkdir "${ARCH}"

	# Remove older commit
	git reset --soft HEAD^

	# Add the packages
	cd "${ARCH}"
	find "${PKGS_DIR}" -name "*.pkg.tar.zst" -exec cp -v "{}" . \;

	repo-add $ARCH_REPO_NAME.db.tar.gz *.pkg.tar.zst
	rename '.tar.gz' '' *.tar.gz

	# Commit
	git add --all --verbose
	git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"
	git config user.name "${GITHUB_ACTOR}"

	git commit -m "Built at $(date +'%d/%m/%Y %H:%M:%S')"

	# Push
	git push -fu origin "${GIT_BRANCH}"
}

set -xe
"$@"
