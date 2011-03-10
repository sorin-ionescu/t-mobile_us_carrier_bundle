#!/bin/bash
#===============================================================================
#          FILE:  make
#   DESCRIPTION:  Makes T-Mobile US carrier bundles.
#        AUTHOR:  Sorin Ionescu <sorin.ionescu@gmail.com>
#       VERSION:  1.0.10
#===============================================================================


version=`git tag | sort -n -k2 -t. | tail -n 1`
ipcc_package_prefix="t-mobile_us_ios4"

cd "$( dirname "$0" )"
mkdir build 2> /dev/null
cd build

for folder in ../src/*; do
	[[ "$folder" =~ 'template' ]] && continue
	find . -type f -name '.DS_Store' -exec rm {} \;
	bundle_name="$(echo "$folder" | sed -e 's/..\/src\///')"	
	bundle_file_name="t-mobile_us_${bundle_name}.ipcc"
	echo Making carrier bundle $bundle_file_name
	rm -rf "$bundle_file_name" Payload
	mkdir -p Payload/TMobile_us.bundle
	cp -LR "$folder"/* Payload/TMobile_us.bundle/ &> /dev/null
	find Payload/TMobile_us.bundle/ -type f -name "*.plist" -exec plutil -convert binary1 {} \;
	find Payload/TMobile_us.bundle/ -type f -name "*.strings" -exec plutil -convert binary1 {} \;
	ln -s TMobile_us.bundle Payload/310260
	zip -r -y "$bundle_file_name" Payload/ &> /dev/null
	rm -rf Payload
done

rm -f *.zip
ipcc_package_name="${ipcc_package_prefix}_${version}.ipcc.zip"
echo Making package $ipcc_package_name
cp ../README.txt .
zip -r "$ipcc_package_name" README.txt *.ipcc &> /dev/null
rm -rf README.txt *.ipcc
cd ..

