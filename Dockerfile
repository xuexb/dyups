FROM ghcr.io/shangxianapp/nginx:latest-alpine

WORKDIR /etc/nginx

LABEL maintainer="xuexb <fe.xiaowu@gmail.com>"
LABEL org.opencontainers.image.source https://github.com/xuexb/dyups

RUN luarocks install lua-cjson
RUN luarocks install luasocket

COPY . .

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]