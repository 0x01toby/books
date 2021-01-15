#!/bin/bash

PWD=$(pwd)

# /usr/local/bin/docsify serve docs
docker run -it -v "${PWD}:/data/docsify" -p 3000:3000 -p 35729:35729 --rm --entrypoint "/bin/sh" my-books:v2


kubectl create secret docker-registry dockerregister \
--docker-server=harbor.taozhang.net.cn \
--docker-username=test \
--docker-password=test \
--docker-email=594909494@qq.com