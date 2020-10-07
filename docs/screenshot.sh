#!/bin/sh
export PYDK=${PYDK:-$(realpath "$(dirname $0)/..")}
FOLDER=$PYDK/docs/screenshots
mkdir -p "$FOLDER"
SHOT=adb-$(date +"%Y-%m-%d_%H-%M-%S").png
echo "Saving to : '$FOLDER/$SHOT'"
export ADB=${PYDK}/android-sdk/platform-tools/adb
echo $ADB
$ADB shell screencap -p | perl -pe 's/\x0D\x0A/\x0A/g' > "$FOLDER/$SHOT"
display "$FOLDER/$SHOT" &
