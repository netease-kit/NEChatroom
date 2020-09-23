#!/bin/bash

echo "pack start..."

GRADLE="../gradlew -b ../build.gradle "

chmod +x ../gradlew

echo Please select output:

echo 1.Audio Room Release All
echo 2.Audio Room Release APK
echo 3.Audio Room Test APK

read answer

if [ $answer -eq 1 ]
then
    echo "Pack Audio Room Release All..."
    ${GRADLE} Pack_Audio_Room_Release_APK_All

elif [ $answer -eq 2 ]
then
    echo "Pack Audio Room Release APK..."
    ${GRADLE} Pack_Audio_Room_Release_APK

elif [ $answer -eq 3 ]
then
    echo "Pack Audio Room Test APK..."
    ${GRADLE} Pack_Audio_Room_Test_APK

else
    echo "Invalid Command"
fi

echo "Pack done..."