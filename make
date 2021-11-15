#!/bin/bash
REDBEAN_STATIC=redbean.com
NAME=soakbean 

all(){
  set -x
  [[ ! -f $REDBEAN_STATIC ]] && wget https://redbean.dev/redbean-1.4.com -O $REDBEAN_STATIC
  [[   -f $REDBEAN_STATIC ]] && cp $REDBEAN_STATIC $NAME.com
  cp middleware/json.lua src/.lua/.
  cd src
  zip -r ../$NAME.com * .lua .init.lua
  chmod 755 ../$NAME.com
  cd -
}

[[ ! -n $1 ]] && { echo "usage: ./make all && ./soakbean.com"; exit 0; }
"$@"
