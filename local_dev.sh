#!/bin/bash

PWD=$(pwd)

# /usr/local/bin/docsify serve docs
docker run -it -v "${PWD}:/data/docsify" -p 3000:3000 -p 35729:35729 --rm --entrypoint "/bin/sh" my-books:v2