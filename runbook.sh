#!/bin/sh
#
cDate="$(date +%y%m%d)"
#
docker build -t "jimurrito/integritoss:$cDate" .
docker build -t jimurrito/integritoss:latest .
# 
# docker run -v ./integ:/integ jimurrito/integritoss
#
docker push "jimurrito/integritoss:$cDate"
docker push jimurrito/integritoss:latest
