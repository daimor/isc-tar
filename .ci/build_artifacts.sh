#!/bin/sh

ARTIFACT=`pwd`/out/zUtils.FileBinaryTar.xml

iris start $ISC_PACKAGE_INSTANCENAME quietly \

/bin/echo -e '' \
  "do \$system.OBJ.Export(\"%zUtils.FileBinaryTar.cls\", \"$ARTIFACT\", \"/diffexport/exportversion=2017.1\")\n" \
  "halt" \
| iris session $ISC_PACKAGE_INSTANCENAME

/bin/echo -e '' \
| iris stop $ISC_PACKAGE_INSTANCENAME quietly

if [ ! -f "$ARTIFACT" ]
then
  exit 1
fi
