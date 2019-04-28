FROM daimor/intersystems-iris:2019.1.0S.111.0-community

WORKDIR /opt

COPY src src
COPY .ci/* /

RUN iris start $ISC_PACKAGE_INSTANCENAME quietly EmergencyID=admin,sys \
 && /bin/echo -e "admin\nsys\n" \
        'do $system.OBJ.ImportDir("/opt/src/", "*.cls", "ck", , 1)\n' \
        'zn "USER"\n' \
        'set ^UnitTestRoot="/opt/tests/src/"\n' \
        'do $system.OBJ.SetQualifiers("/nodelete")\n' \
        'halt\n' \
  | iris session $ISC_PACKAGE_INSTANCENAME \
 && /bin/echo -e "admin\nsys\n" \
  | iris stop $ISC_PACKAGE_INSTANCENAME quietly
