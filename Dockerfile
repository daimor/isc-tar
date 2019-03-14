FROM daimor/intersystems-iris:2019.1.0S.111.0-community

WORKDIR /opt/src

COPY ./src/ ./

RUN iris start $ISC_PACKAGE_INSTANCENAME quietly EmergencyID=admin,sys \
 && /bin/echo -e "admin\nsys\n" \
        'Do ##class(Security.System).Get(,.p)\n' \
        'Set p("AutheEnabled")=$zb(p("AutheEnabled"),16,7)\n' \
        'Do ##class(Security.System).Modify(,.p)\n' \
        'do $system.OBJ.ImportDir("/opt/src/", "*.cls", "ck", , 1)\n' \
        'zn "USER"\n' \
        'set ^UnitTestRoot="/opt/tests/"\n' \
        'do $system.OBJ.SetQualifiers("/nodelete")\n' \
        'halt\n' \
  | iris session $ISC_PACKAGE_INSTANCENAME \
 && /bin/echo -e "admin\nsys\n" \
  | iris stop $ISC_PACKAGE_INSTANCENAME quietly

WORKDIR $ISC_PACKAGE_INSTALLDIR
