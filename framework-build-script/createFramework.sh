#!/bin/bash
export LANG=en_US.UTF-8

INSTALL_PATH=`cd .;pwd`
REPOS_PATH=`cd ~;pwd`/.cocoapods/repos
WORK_PATH="$PWD"
[ -z $APP_TEMPLATE ] && { APP_TEMPLATE="$INSTALL_PATH/Template"; }

appname=$1
if [[ -z "$appname" ]]; then
	read -p 'Specify an framework name: ' appname
	if [[ -z "$appname" ]]; then
		echo "ERROR: framework name is no valid.";
		exit 1;
	fi
fi

echo "framework name:${appname}"

BASE_APPNAME=`basename $APP_TEMPLATE`
BASEDIR=$(dirname $APP_TEMPLATE)

if [ -d "$appname" ]; then
	rm -rf $appname
fi

function proc_file_content() {
	sed "s/$BASE_APPNAME/${appname}/g" $1 > $1'.tmp'
	rm -f $1
	mv $1'.tmp' $1
}

function make_target() {
	target=`echo $1 | sed "s/$BASE_APPNAME/${appname}/g"`
	target_length=${#target}
	proj="$BASEDIR"
	proj_length=${#proj}+1
	target_length=$target_length-$proj_length
	target=${target:proj_length:target_length}
	echo $target
}

function replace_filename() {

	source=$1
	target=`make_target "$1"`
	echo $target

	if [ -d "$source" ] ; then
		mkdir -p $target
	else
		if [[ ! -d `dirname $target` ]]; then
			mkdir -p `dirname $target`
		fi
		cp -v $source $target
	fi

	proj='project.pbxproj'
	position=${#target}-${#proj}
	length=${#proj}
	if [ ${target:position:length} == $proj ] ; then
		proc_file_content $target
	fi

	proj='xcscheme'
	position=${#target}-${#proj}
	length=${#proj}
	if [ ${target:position:length} == $proj ] ; then
		proc_file_content $target
	fi

	proj='Aggregate.xcscheme'
	position=${#target}-${#proj}
	length=${#proj}
	if [ ${target:position:length} == $proj ] ; then
		proc_file_content $target
	fi

	proj='Info.plist'
	position=${#target}-${#proj}
	length=${#proj}
	if [ ${target:position:length} == $proj ] ; then
		proc_file_content $target
	fi

	proj='contents.xcworkspacedata'
	position=${#target}-${#proj}
	length=${#proj}
	if [ ${target:position:length} == $proj ] ; then
		proc_file_content $target
	fi

	proj="${appname}.podspec"
	position=${#target}-${#proj}
	length=${#proj}
	if [ ${target:position:length} == $proj ] ; then
		proc_file_content $target
	fi

	proj="Podfile"
	position=${#target}-${#proj}
	length=${#proj}
	if [ ${target:position:length} == $proj ] ; then
		proc_file_content $target
	fi

    proj="release.sh"
	position=${#target}-${#proj}
	length=${#proj}
	if [ ${target:position:length} == $proj ] ; then
		proc_file_content $target
	fi


	position=${#target}-2
	length=2
	if [ ${target:position:length} == '.h' ] ; then
		proc_file_content $target
	fi

	if [ ${target:position:length} == '.m' ] ; then
		proc_file_content $target
	fi

}

function list() {
	for file in `ls $1` 
	do

		replace_filename $1/$file

		if [ -d "$1/$file" ] ; then
			list "$1/$file";
		fi

	done
}

list "$APP_TEMPLATE"


