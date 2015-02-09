#!/bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

if [ "$ACTION" = "clean" ]
  then
    rm -rf ./out
    rm -rf "$2" "$4"
    exit 0
  fi

xcodebuild -project contentbuilder.xcodeproj -configuration 'Release' -scheme contentbuilder -derivedDataPath ./out
./out/Build/Products/Release/contentbuilder "$1" "$2" "$3" "$4"

