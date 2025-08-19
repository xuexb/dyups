FROM ghcr.io/shangxianapp/nginx:latest-alpine

WORKDIR /etc/nginx

LABEL maintainer="xuexb <fe.xiaowu@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/xuexb/dyups"

# 安装编译依赖
RUN apk add --no-cache --virtual .build-deps \
        gcc \
        musl-dev \
        lua5.1-dev \
        openssl-dev \
        git \
        make \
    && apk add --no-cache lua5.1 \
    # 使用特定版本的lua-cjson避免manifest问题
    && cd /tmp \
    && git clone https://github.com/openresty/lua-cjson.git \
    && cd lua-cjson \
    && make LUA_INCLUDE_DIR=/usr/include/lua5.1 \
    && make install LUA_INCLUDE_DIR=/usr/include/lua5.1 LUA_LIB_DIR=/usr/local/lib/lua/5.1 \
    # 安装luasocket
    && cd /tmp \
    && git clone https://github.com/diegonehab/luasocket.git \
    && cd luasocket \
    && make LUAINC_linux=/usr/include/lua5.1 \
    && make install LUAINC_linux=/usr/include/lua5.1 \
    # 清理临时文件和构建依赖
    && rm -rf /tmp/lua-cjson /tmp/luasocket \
    && apk del .build-deps

COPY . .

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
