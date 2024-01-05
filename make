#!/bin/bash
REDBEAN_STATIC=redbean.com
VERSION=2.2
NAME=soakbean 

to_elf(){
  zip -d $NAME.com .ape
  zip -sf $NAME.com
  ./$NAME.com -h &>/dev/null
}

all(){
  set -x
  [[ ! -f $REDBEAN_STATIC ]] && wget https://redbean.dev/redbean-${VERSION}.com -O $REDBEAN_STATIC
  [[   -f $REDBEAN_STATIC ]] && cp $REDBEAN_STATIC $NAME.com
  cp middleware/json.lua src/.lua/.
  cd src
  zip -q -r ../$NAME.com * .lua .init.lua
  chmod 755 ../$NAME.com
  set +x
  cd -
  ls -lah $NAME.com
}

docker(){
  docker=$(which docker)
  to_elf
  set -x
  $docker build . -t $NAME       && \
  $docker images | grep $NAME    && \
  $docker run -p 8080:8080 $NAME
}

[[ ! -n $1 ]] && { echo "usage: ./make all && ./soakbean.com"; exit 0; }
"$@"
