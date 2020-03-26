FROM store/intersystems/iris-community:2020.1.0.202.0

WORKDIR /opt

COPY src src
COPY .ci/* /

RUN iris start $ISC_PACKAGE_INSTANCENAME quietly \
 && /bin/echo -e "" \
        'do $system.OBJ.ImportDir("/opt/src/", "*.cls", "ck", , 1)\n' \
        'zn "USER"\n' \
        'set ^UnitTestRoot="/opt/tests/"\n' \
        'do $system.OBJ.SetQualifiers("/nodelete")\n' \
        'halt\n' \
  | iris session $ISC_PACKAGE_INSTANCENAME \
 && iris stop $ISC_PACKAGE_INSTANCENAME quietly
