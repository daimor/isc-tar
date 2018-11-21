FROM daimor/intersystems-iris:2018.1

WORKDIR /opt/src

COPY ./src/ ./

RUN iris start $ISC_PACKAGE_INSTANCENAME quietly \
 && /bin/echo -e \
      "do \$system.OBJ.ImportDir(\"$(pwd)\", \"*.cls\", \"ck\", , 1)\n" \
      "halt" \
  | iris session $ISC_PACKAGE_INSTANCENAME \
 && iris stop $ISC_PACKAGE_INSTANCENAME quietly

WORKDIR $ISC_PACKAGE_INSTALLDIR
