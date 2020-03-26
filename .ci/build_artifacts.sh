#!/bin/sh

ARTIFACT=`pwd`/out/zUtils.FileBinaryTar.xml

iris start $ISC_PACKAGE_INSTANCENAME quietly \

iris session $ISC_PACKAGE_INSTANCENAME "##class(%SYSTEM.OBJ).Export(\"%zUtils.FileBinaryTar.cls\",\"$ARTIFACT\",\"/diffexport/exportversion=2017.1\")"

iris stop $ISC_PACKAGE_INSTANCENAME quietly

if [ ! -f "$ARTIFACT" ]
then
  exit 1
fi
