FROM node:alpine3.12

RUN npm i docsify-cli -g --registry=https://registry.npm.taobao.org

WORKDIR /data/docsify

EXPOSE 3000
EXPOSE 35729

CMD ["/usr/local/bin/docsify", "serve", "docs"]