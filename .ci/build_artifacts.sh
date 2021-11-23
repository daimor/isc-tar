#!/bin/sh

set -x 

ARTIFACT=`pwd`/out/zUtils.FileBinaryTar.xml

mkdir -p $( dirname $ARTIFACT ) 

iris start $ISC_PACKAGE_INSTANCENAME \

iris session $ISC_PACKAGE_INSTANCENAME "##class(%SYSTEM.OBJ).Export(\"%zUtils.FileBinaryTar.cls\",\"$ARTIFACT\",\"/diffexport/exportversion=2017.1\")"

iris stop $ISC_PACKAGE_INSTANCENAME quietly

if [ ! -f "$ARTIFACT" ]
then
  exit 1
fi
