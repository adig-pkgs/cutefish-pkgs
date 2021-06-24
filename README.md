## These are not official PKGBUILDs, though you may like to use them

Run the `install_all.sh` script to install all packages of the groups `cutefish-git` (these packages)

These packages may provide additional features as the cutefish os are updated. For eg, currently the arch repo cutefish-dock doesn't have hide functionality which is now available in the cutefish repos.

* All of these packages will replace the 'older' (& likely more stable) packages installed through arch repositories.
* All of these belong to the `cutefish-git` group

> It is intentional to look like all have 90-95% exactly same PKGBUILDS, and hence **use as much substitutions with variable names as possible, instead of hardcoding the name/url.**

> remove\_translation patches: You can simply remove the prepare step altogether, in any of them where you want to keep the translations, i originally did so because the build failed for me with translations, though you should be fine with QT Linguist i guess 👍

![Screenshot of cutefish-git group packages](https://user-images.githubusercontent.com/37269665/123208317-7bcf2a00-d4dc-11eb-8548-1c30a27ded39.png)

Checkout the Cutefish OS repositories at https://github.com/cutefishos
