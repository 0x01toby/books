#!/bin/bash

# protobuf

# 根目录
ROOT_DIR=$(cd "$(dirname "$0")"; pwd)

# 找到proto文件
for file in "${ROOT_DIR}"/api/protos/*.proto; do
# generate files
mkdir -p "${ROOT_DIR}/api/clients/go/pb"
mkdir -p "${ROOT_DIR}/api/clients/php/pb"

/usr/bin/protoc --proto_path="${ROOT_DIR}"/api/protos \
-I /protobuf/google/protobuf \
-I /protobuf \
-I . \
--go_out=plugins=grpc:"${ROOT_DIR}/api/clients/go/pb" \
--php_out=plugins=grpc_php_plugin:"${ROOT_DIR}/api/clients/php/pb" \
--grpc-gateway_out=logtostderr=true:"${ROOT_DIR}/api/clients/go/pb" \
--openapiv2_out=logtostderr=true:"${ROOT_DIR}/assets" \
"${file}"

chmod -R 777 "${ROOT_DIR}/api/clients"
chmod -R 777 "${ROOT_DIR}/assets"

done