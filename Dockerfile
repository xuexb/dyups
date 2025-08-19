FROM ghcr.io/shangxianapp/nginx:latest-alpine

WORKDIR /etc/nginx

LABEL maintainer="xuexb <fe.xiaowu@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/xuexb/dyups"

# 使用Alpine包管理器安装lua模块，避免luarocks manifest问题
RUN apk add --no-cache lua5.1-cjson lua5.1-socket

COPY . .

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
