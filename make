#!/bin/bash
#===============================================================================
#
#          FILE:  make-package
#
#         USAGE:  ./make-package
#
#   DESCRIPTION:  Makes T-Mobile US carrier bundles.
#
#        AUTHOR:  Sorin Ionescu <sorin.ionescu@gmail.com>
#       VERSION:  1.0.9
#       CREATED:  2010-08-04 18:58:43-04:00
#===============================================================================

VERSION=`git tag | sort -n -k2 -t. | tail -n 1`

IPCC_PACKAGE_VERSION=1
IPCC_PACKAGE_PREFIX="t-mobile_us_ios4"

DEB_PACKAGE_VERSION=1
DEB_PACKAGE_PREFIX="tmobileus"

cd $( dirname $0 )
mkdir build
cd build

for folder in ../src/*
do
	if [[ $folder =~ 'template' ]]
	then
		continue
	fi
	
	find . -type f -name '.DS_Store' -exec rm {} \;
	bundle_name=$(echo $folder | sed -e 's/..\/src\///')
	
	# IPCC
	bundle_file_name="t-mobile_us_${bundle_name}.ipcc"
	echo Making carrier bundle $bundle_file_name
	rm -rf $bundle_file_name Payload
	mkdir -p Payload/TMobile_us.bundle
	cp -LR $folder/* Payload/TMobile_us.bundle/ &> /dev/null
	find Payload/TMobile_us.bundle/ -type f -name "*.plist" -exec plutil -convert binary1 {} \;
	find Payload/TMobile_us.bundle/ -type f -name "*.strings" -exec plutil -convert binary1 {} \;
	ln -s TMobile_us.bundle Payload/310260
	zip -r -y "$bundle_file_name" Payload/ &> /dev/null
	rm -rf Payload
done

rm -f *.zip

ipcc_package_name=${IPCC_PACKAGE_PREFIX}_${VERSION}.ipcc.zip
echo Making package $ipcc_package_name
cp ../README.txt .
zip -r $ipcc_package_name README.txt *.ipcc &> /dev/null
rm -rf README.txt *.ipcc

cd ..
