#!/bin/sh 

export LANG=en_US.UTF-8

# 捕获ERR信号
trap 'exit 2' ERR

# 清理
PRODUCT_DIR="Products"
rm -rf "${PRODUCT_DIR}"
[[ ! -d "$PRODUCT_DIR" ]] && { mkdir -pv "$PRODUCT_DIR"; }

# Framework配置
FRAMEWORK_NAME=`xcodebuild -sdk iphoneos -showBuildSettings | grep 'PRODUCT_NAME' | awk 'NR>1' | awk -F '=' '{print $2}' | awk 'gsub(/^ *| *$/,"")'`
FRAMEWORK_VERSION=1.0
FRAMEWORK_CONFIG=Release

# workspace & project & scheme
WORKSPACE=
PROJECT=
files=`ls`
for file in $files
do
    if [ `echo $file | grep 'xcworkspace'` ];then
        WORKSPACE=$file
        echo "=> found xcode workspace : '$WORKSPACE'"
    elif [ `echo $file | grep 'xcodeproj'` ];then
        PROJECT=$file
        echo "=> found xocde project : '$PROJECT'"
    fi  
done;

PROJECT=`ls . | grep xcodeproj | cut -d. -f1`
#SCHEMES=`xcodebuild -list |sed -n '/Schemes/,$p' | awk 'NR>1'`
SCHEME=${PROJECT}


# 编译真机部分
DEVICE_ARCHS="$1"
[ -z "$DEVICE_ARCHS" ] && {
DEVICE_ARCHS="armv7 arm64";
};

for arch in $DEVICE_ARCHS; do
BUILD_ARCHS="$BUILD_ARCHS -arch $arch"
done

echo "----------------------------${FRAMEWORK_NAME} - ${FRAMEWORK_CONFIG}----------------------------"
echo ">>> 开始编译 ${WORKSPACE} - ${PROJECT} - ${DEVICE_ARCHS}"

set -o history -o histexpand
if [ $WORKSPACE ];then
    xcodebuild clean archive -workspace $WORKSPACE -scheme "$SCHEME" -configuration "$FRAMEWORK_CONFIG" -sdk iphoneos $BUILD_ARCHS INSTALL_PATH="${PRODUCT_DIR}" SKIP_INSTALL=NO STRIP_INSTALLED_PRODUCT=YES DSTROOT= CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO CODE_SIGN_IDENTITY= 
else 
    xcodebuild clean archive -configuration "$FRAMEWORK_CONFIG" -scheme "$SCHEME" -sdk iphoneos $BUILD_ARCHS INSTALL_PATH="${PRODUCT_DIR}" SKIP_INSTALL=NO STRIP_INSTALLED_PRODUCT=YES DSTROOT= CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO CODE_SIGN_IDENTITY= 
fi

DEVICE_FRAMEWORK=${PRODUCT_DIR}/${FRAMEWORK_NAME}.framework
echo ">>> 完成真机编译, 路径: ${DEVICE_FRAMEWORK}"


# 编译模拟器部分
DESTINATION_NAME=$(instruments -s devices | egrep 'iPhone \d\w? \w*' | tail -n 1 | sed 's/ (.*//')
DESTINATION="platform=iOS Simulator,name=${DESTINATION_NAME}"

echo ">>> 开始编译 ${WORKSPACE} - ${PROJECT} for ${DESTINATION_NAME}"

set -o history -o histexpand
if [ $WORKSPACE ];then
    xcodebuild clean build -workspace $WORKSPACE -configuration "$FRAMEWORK_CONFIG" -scheme "$SCHEME" -sdk iphonesimulator -destination "$DESTINATION" 
    BUILD_SETTINGS=$(xcodebuild clean build -workspace $WORKSPACE -configuration "$FRAMEWORK_CONFIG" -scheme "$SCHEME" -sdk iphonesimulator -destination "$DESTINATION" -showBuildSettings 2>/dev/null)
    eval "$(echo "$BUILD_SETTINGS" | grep BUILT_PRODUCTS_DIR | grep " = " | sed "s/ = /=/g" | sed "s/    //g")" 
else   
    xcodebuild clean build -configuration "$FRAMEWORK_CONFIG" -scheme "$SCHEME" -sdk iphonesimulator -destination "$DESTINATION" 
    BUILD_SETTINGS=$(xcodebuild clean build -configuration "$FRAMEWORK_CONFIG" -scheme "$SCHEME" -sdk iphonesimulator -destination "$DESTINATION" -showBuildSettings 2>/dev/null)
    eval "$(echo "$BUILD_SETTINGS" | grep BUILT_PRODUCTS_DIR | grep " = " | sed "s/ = /=/g" | sed "s/    //g")" 
fi


SIMULATOR_FRAMEWORK=${BUILT_PRODUCTS_DIR}/${FRAMEWORK_NAME}.framework
echo ">>> 完成模拟器编译, 路径: ${SIMULATOR_FRAMEWORK}"


# 合并
lipo -create "${DEVICE_FRAMEWORK}/${FRAMEWORK_NAME}" "${SIMULATOR_FRAMEWORK}/${FRAMEWORK_NAME}" -output "${PRODUCT_DIR}/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"
PWD=$(cd `dirname $0`; pwd)
echo ">>> 完成合并, 路径: ${PWD}/${PRODUCT_DIR}"


# 清理
find $PRODUCT_DIR -depth 1 | grep "Debug\|Release" | xargs rm -rf
echo "----------------------------${FRAMEWORK_NAME} - ${FRAMEWORK_CONFIG}----------------------------"

exit 0
