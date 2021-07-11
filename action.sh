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
GITHUB_REPO_NAME=${GITHUB_REPOSITORY}

initialize() {
	pacman -Syu --noconfirm --needed git ccache ninja

	echo "${BUILD_USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${BUILD_USER}
	echo "cache_dir = ${CCACHE_DIR}" > /etc/ccache.conf

	useradd -m ${BUILD_USER}
	chown -R ${BUILD_USER}:${BUILD_USER} .
}

build() {
	export MAKEFLAGS="-j$(nproc)"

	for PKGBUILD_PATH in $(find . -name "PKGBUILD"); do
		pkgbuild_dir=${PKGBUILD_PATH%PKGBUILD}
		pushd "$pkgbuild_dir"
			sudo -u "${BUILD_USER}" makepkg -sr --noconfirm --needed
		popd
	done

	cp -rv *.pkg.tar.zst "${PKGS_DIR}/"
}

publish() {
	# Checkout the publishing branch
	git checkout "${GIT_BRANCH}"
	mkdir -pv "${ARCH}"

	# Remove older commit
	git reset --soft HEAD^
	rm -rv "${ARCH}/"*

	# Add the packages
	cd "${ARCH}"
	cp -rv "${PKGS_DIR}/"*.pkg.tar.zst .
	repo-add ${GITHUB_REPO_NAME}.db.tar.gz *.pkg.tar.zst
	rename '.tar.gz' '' *.tar.gz

	# Commit
	git add --all
	git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"
	git config user.name "${GITHUB_ACTOR}"

	git commit -m "Built at $(date +'%d/%m/%Y %H:%M:%S')"

	# Push
	git remote add origin "${GIT_REMOTE}"
	git push -fu origin "${GIT_BRANCH}"
}

set -xe
"$@"
