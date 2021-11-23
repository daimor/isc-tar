#!/bin/sh

ARTIFACT=`pwd`/out/zUtils.FileBinaryTar.xml

iris session $ISC_PACKAGE_INSTANCENAME "##class(%SYSTEM.OBJ).Export(\"%zUtils.FileBinaryTar.cls\",\"$ARTIFACT\",\"/diffexport/exportversion=2017.1\")"

exit 1
