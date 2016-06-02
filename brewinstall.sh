#!/bin/sh -e

# Install all the commands necessary for running the Skin Makefile
# Based on `install.sh` but with the following updates:
#
# - Uses `brew` to install packages on OS X (instead of apt-get)
# - Uses the same version specs from the Makefile


# add to common packages
# curl      (already on OS X)
# md5sum    (md5sha1sum)
# optipng
# npm
brew install md5sha1sum
brew install optipng
brew install node
brew install npm
brew install jq

# pip install ...
# pillow (required for Glue)
# glue
# verify_version_spec
pip install "pillow < 2.9";
pip install "glue < 0.12";
pip install verify_version_spec;


# npm install -g
# uglify-js
# clean-css
# component
# bower
# less
# autoprefixer
# stripmq
npm install -g "uglify-js@<3.0";
npm install -g "clean-css@<4.0";
npm install -g component;
npm install -g "bower@<1.7";
npm install -g less;
npm install -g autoprefixer-cli;
npm install -g stripmq;

# install custom fork of suitcss
npm install -g git://github.com/jkenlooper/preprocessor#0.5.0-depends.1;
