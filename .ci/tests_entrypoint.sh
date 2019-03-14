#!/bin/sh

iris start $ISC_PACKAGE_INSTANCENAME quietly

/bin/echo -e \
  'set ^UnitTestRoot="/opt/tests/cls"\n' \
  'do ##class(%UnitTest.Manager).RunTestSuites()\n' \
  'halt' \
| iris session $ISC_PACKAGE_INSTANCENAME | tee /tmp/tests.log

iris stop $ISC_PACKAGE_INSTANCENAME quietly

if ! grep -iq "All PASSED" /tmp/tests.log 
then
  exit 1
fi