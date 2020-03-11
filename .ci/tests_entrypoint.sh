#!/bin/sh

TESTS=`pwd`/tests/src

iris start $ISC_PACKAGE_INSTANCENAME quietly \

/bin/echo -e '' \
  "set ^UnitTestRoot=\"$TESTS\"\n" \
  'do ##class(%UnitTest.Manager).RunTest()\n' \
  'halt\n' \
| iris session $ISC_PACKAGE_INSTANCENAME | tee /tmp/tests.log

/bin/echo -e '' \
| iris stop $ISC_PACKAGE_INSTANCENAME quietly

if ! grep -iq "All PASSED" /tmp/tests.log 
then
  exit 1
fi