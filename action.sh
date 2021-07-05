for PKGBUILD_PATH in $(find . -name "PKGBUILD"); do
	pkgbuild_dir=${PKGBUILD_PATH%PKGBUILD}
	pushd "$pkgbuild_dir"
		makepkg -s --noconfirm --needed
	popd
done

