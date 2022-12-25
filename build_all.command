#! /bin/bash

#set -x

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd $SCRIPT_DIR

rm -rf output
mkdir -p output

speeds=($(cat playlists.txt  | awk '{print $1}' | grep "^[0-9][0-9]*$"))

for i in "${speeds[@]}"; do
  APPNAME="$i"
  echo "Building $APPNAME"
  osacompile -x -o output/$APPNAME.app Main.scpt

  if [ -f "images/${APPNAME}.png" ]; then
    pushd output

    mkdir -p "icons.iconset"
    sips -z 256 256 "../images/${APPNAME}.png" --out "icons.iconset/icon_256x256.png"
    iconutil -c icns "icons.iconset" # Compile the .iconset folder to a .icns file
    rm -rf "icons.iconset"

    mv -f "icons.icns" "${APPNAME}.app/Contents/Resources/applet.icns"
    popd
  fi

  /usr/bin/codesign --force --sign - --timestamp=none "output/${APPNAME}.app"
done

cp playlists.txt output/
zip -qr deploy.zip output/*

