#!/bin/sh

iris start $ISC_PACKAGE_INSTANCENAME quietly EmergencyID=admin,sys \

/bin/echo -e 'admin\nsys\n' \
  'set ^UnitTestRoot="/opt/tests/cls"\n' \
  'do ##class(%UnitTest.Manager).RunTest()\n' \
  'halt\n' \
| iris session $ISC_PACKAGE_INSTANCENAME | tee /tmp/tests.log

/bin/echo -e 'admin\nsys\n' \
| iris stop $ISC_PACKAGE_INSTANCENAME quietly

if ! grep -iq "All PASSED" /tmp/tests.log 
then
  exit 1
fi