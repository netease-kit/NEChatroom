#!/bin/bash
SDK_URL=$1
SDK_ZIP="nim_sdk.zip"
UNZIP_DIR="unzip_sdk"
DEMO_LIB_PATH="../app/libs"
echo "start..."

# eg : http://10.216.25.91/Android-nim-test-pack/nim-outputs-7.1.0-20191206-4097f78/NIM_Android_SDK_v7.1.0.zip
if [[ ! -n ${SDK_URL} ]]; then
    echo "Err input arg !!!  Example : \n update_sdk.sh http://xxxx/NIM_Android_SDK_vX.X.X.zip"
    exit 0
else
    echo ${SDK_URL}
fi

echo ".........................start download zip sdk........................."
curl -o ${SDK_ZIP} ${SDK_URL}
mkdir ${UNZIP_DIR}
tar -zxvf ${SDK_ZIP} -C ${UNZIP_DIR}
pwd

echo ".........................remove old sdk from demo ........................."
rm ${DEMO_LIB_PATH}/nrtc-*.jar
rm ${DEMO_LIB_PATH}/nim-*.jar

echo ".........................start cp jar to demo ........................."
cp -f ${UNZIP_DIR}/libs/yunxin-nos-*.jar ${DEMO_LIB_PATH}/
cp -f ${UNZIP_DIR}/libs/yunxin-report-*.jar ${DEMO_LIB_PATH}/
cp -f ${UNZIP_DIR}/libs/nim-basesdk-*.jar ${DEMO_LIB_PATH}/
cp -f ${UNZIP_DIR}/libs/nim-avchat-*.jar ${DEMO_LIB_PATH}/
cp -f ${UNZIP_DIR}/libs/nim-chatroom-*.jar ${DEMO_LIB_PATH}/
cp -f ${UNZIP_DIR}/libs/nrtc-sdk.jar ${DEMO_LIB_PATH}/nrtc-sdk.jar


echo ".........................start cp so to demo ........................."
cp -f ${UNZIP_DIR}/libs/armeabi-v7a/libnrtc_sdk.so  ${DEMO_LIB_PATH}/armeabi-v7a/
cp -f ${UNZIP_DIR}/libs/arm64-v8a/libnrtc_sdk.so  ${DEMO_LIB_PATH}/arm64-v8a/
cp -f ${UNZIP_DIR}/libs/x86/libnrtc_sdk.so  ${DEMO_LIB_PATH}/x86/
cp -f ${UNZIP_DIR}/libs/x86_64/libnrtc_sdk.so  ${DEMO_LIB_PATH}/x86_64/

cp -f ${UNZIP_DIR}/libs/armeabi-v7a/libyxbase.so  ${DEMO_LIB_PATH}/armeabi-v7a/
cp -f ${UNZIP_DIR}/libs/arm64-v8a/libyxbase.so  ${DEMO_LIB_PATH}/arm64-v8a/
cp -f ${UNZIP_DIR}/libs/x86/libyxbase.so  ${DEMO_LIB_PATH}/x86/
cp -f ${UNZIP_DIR}/libs/x86_64/libyxbase.so  ${DEMO_LIB_PATH}/x86_64/

#
rm ${SDK_ZIP}
rm -rf ${UNZIP_DIR}

echo ${SDK_URL}
echo "done"