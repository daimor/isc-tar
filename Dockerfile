FROM store/intersystems/iris-community:2020.4.0.521.0

WORKDIR /home/irisowner/isc-tar

COPY src src
COPY .ci/* /

RUN iris start $ISC_PACKAGE_INSTANCENAME quietly \
 && /bin/echo -e "" \
        'do $system.OBJ.ImportDir("/home/irisowner/isc-tar/src/", "*.cls", "ck", , 1)\n' \
        'zn "USER"\n' \
        'set ^UnitTestRoot="/home/irisowner/isc-tar/tests/"\n' \
        'do $system.OBJ.SetQualifiers("/nodelete")\n' \
        'halt\n' \
  | iris session $ISC_PACKAGE_INSTANCENAME \
 && iris stop $ISC_PACKAGE_INSTANCENAME quietly
