#!/bin/bash
#===============================================================================
#          FILE:  make
#   DESCRIPTION:  Makes T-Mobile US carrier bundles.
#        AUTHOR:  Sorin Ionescu <sorin.ionescu@gmail.com>
#       VERSION:  1.0.12
#===============================================================================


version=`git tag | sort -n -k2 -t. | tail -n 1`
ipcc_package_prefix="t-mobile_us_ios5"
deb_package_prefix="tmobileus"
deb_package_version=1

cd "$( dirname "$0" )"
mkdir build 2> /dev/null
cd build

for folder in ../src/*; do
	[[ "$folder" =~ 'template' ]] && continue
	find . -type f -name '.DS_Store' -exec rm {} \;

	# iTunes
	bundle_name="$(echo "$folder" | sed -e 's/..\/src\///')"
	bundle_file_name="t-mobile_us_${bundle_name}.ipcc"
	echo Making iTunes package $bundle_file_name
	mkdir -p Payload/TMobile_us.bundle
	cp -RL "$folder"/* Payload/TMobile_us.bundle
	rm -rf Payload/TMobile_us.bundle/debian
	find Payload/TMobile_us.bundle/ -type f \( \
		   -name "*.plist" \
		-o -name "*.strings" \
		-o -name "*.pri" \
		\) -exec plutil -convert binary1 {} \;
	ln -s TMobile_us.bundle Payload/310260
	zip -r -y -q "$bundle_file_name" Payload

	# Cydia
	bundle_name="$(echo $bundle_name | sed -e 's/_//g')"
	bundle_file_name="${deb_package_prefix}${bundle_name}${version}.${deb_package_version}"
	echo Making Cydia package $bundle_file_name.deb
	mkdir "$bundle_file_name"
	mkdir -p "${bundle_file_name}/DEBIAN"
	mkdir -p "${bundle_file_name}/System/Library/Carrier Bundles/iPhone"
	cp -R "${folder}/debian/" "${bundle_file_name}/DEBIAN"
	cp -RH Payload/ "${bundle_file_name}/System/Library/Carrier Bundles/iPhone"
	dpkg -b "$bundle_file_name" "${bundle_file_name}.deb" &>/dev/null

	rm -rf Payload "$bundle_file_name"
done

rm -f *.zip
ipcc_package_name="${ipcc_package_prefix}_${version}.ipcc.zip"
echo Making package $ipcc_package_name
cp ../README.txt .
zip -r -y -q "$ipcc_package_name" README.txt *.ipcc &> /dev/null
rm -rf README.txt *.ipcc

deb_package_name="${deb_package_prefix}${version}.${deb_package_version}.deb.zip"
echo Making package "$deb_package_name"
zip "$deb_package_name" *.deb &> /dev/null
rm -rf *.deb

