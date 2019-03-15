#!/bin/sh

iris start $ISC_PACKAGE_INSTANCENAME quietly

ARTIFACT=`pwd`/out/zUtils.FileBinaryTar.xml

/bin/echo -e 'admin\nsys\n' \
  "do \$system.OBJ.Export(\"%zUtils.FileBinaryTar.cls\", \"$ARTIFACT\", \"/diffexport\")\n" \
  "halt" \
| iris session $ISC_PACKAGE_INSTANCENAME

/bin/echo -e 'admin\nsys\n' \
| iris stop $ISC_PACKAGE_INSTANCENAME quietly

if [ ! -f "$ARTIFACT" ]
then
  exit 1
fi

sed -i.bak 's/^<Export generator="IRIS" .*$/<Export generator="Cache" version="25">/g' $ARTIFACT
rm -rf "$ARTIFACT.bak"