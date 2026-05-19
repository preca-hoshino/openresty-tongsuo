# Dockerfile - Ubuntu Noble with Tongsuo (铜锁)
# Based on https://github.com/openresty/docker-openresty
# Modified: OpenSSL 3.5.6 → Tongsuo 8.5.0-pre1 (国密 SM2/SM3/SM4/TLCP/NTLS)

ARG RESTY_IMAGE_BASE="ubuntu"
ARG RESTY_IMAGE_TAG="noble"

FROM ${RESTY_IMAGE_BASE}:${RESTY_IMAGE_TAG}

LABEL maintainer="OpenResty Tongsuo Image"
LABEL description="OpenResty 1.29.2.4 + Tongsuo 8.5.0-pre1 with SM2/SM3/SM4/TLCP/NTLS support"

# Docker Build Arguments
ARG RESTY_IMAGE_BASE="ubuntu"
ARG RESTY_IMAGE_TAG="noble"
ARG RESTY_VERSION="1.29.2.4"
ARG RESTY_LUAROCKS_VERSION="3.13.0"

# === Tongsuo (铜锁) replacing OpenSSL ===
ARG RESTY_OPENSSL_VERSION="8.5.0-pre1"
ARG RESTY_OPENSSL_URL_BASE="https://github.com/Tongsuo-Project/Tongsuo/archive/refs/tags"
# Tongsuo 8.4+ removed: Camellia, SEED, RC5, MD2, MD4, MDC2, IDEA, Blowfish, CAST, RIPEMD
# Tongsuo 8.5+ (OpenSSL 3.5.x): enable-ssl3/enable-ssl3-method removed from OpenSSL 3.x
# enable-ntls: 国密 TLCP/NTLS support
# Start with minimal options; add more as verified
ARG RESTY_OPENSSL_BUILD_OPTIONS="enable-ntls"

# https://github.com/openresty/openresty-packaging/blob/master/deb/openresty-pcre2/debian/rules
ARG RESTY_PCRE_VERSION="10.47"
ARG RESTY_PCRE_SHA256="c08ae2388ef333e8403e670ad70c0a11f1eed021fd88308d7e02f596fcd9dc16"
ARG RESTY_PCRE_BUILD_OPTIONS="--enable-jit --enable-pcre2grep-jit --disable-bsr-anycrlf --disable-coverage --disable-ebcdic --disable-fuzz-support \
    --disable-jit-sealloc --disable-never-backslash-C --enable-newline-is-lf --enable-pcre2-8 --enable-pcre2-16 --enable-pcre2-32 \
    --enable-pcre2grep-callout --enable-pcre2grep-callout-fork --disable-pcre2grep-libbz2 --disable-pcre2grep-libz --disable-pcre2test-libedit \
    --enable-percent-zt --disable-rebuild-chartables --enable-shared --disable-static --disable-silent-rules --enable-unicode --disable-valgrind \
    "

ARG RESTY_J="2"

# https://github.com/openresty/openresty-packaging/blob/master/deb/openresty/debian/rules
ARG RESTY_CONFIG_OPTIONS="\
    --with-compat \
    --without-http_rds_json_module \
    --without-http_rds_csv_module \
    --without-lua_rds_parser \
    --without-mail_pop3_module \
    --without-mail_imap_module \
    --without-mail_smtp_module \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_geoip_module=dynamic \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_image_filter_module=dynamic \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-http_v3_module \
    --with-http_xslt_module=dynamic \
    --with-ipv6 \
    --with-mail \
    --with-mail_ssl_module \
    --with-md5-asm \
    --with-sha1-asm \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-threads \
    "
ARG RESTY_CONFIG_OPTIONS_MORE=""
ARG RESTY_LUAJIT_OPTIONS="--with-luajit-xcflags='-DLUAJIT_NUMMODE=2 -DLUAJIT_ENABLE_LUA52COMPAT'"
ARG RESTY_PCRE_OPTIONS="--with-pcre-jit"

ARG RESTY_ADD_PACKAGE_BUILDDEPS=""
ARG RESTY_ADD_PACKAGE_RUNDEPS=""
ARG RESTY_EVAL_PRE_CONFIGURE=""
ARG RESTY_EVAL_POST_DOWNLOAD_PRE_CONFIGURE=""
ARG RESTY_EVAL_PRE_MAKE=""
ARG RESTY_EVAL_POST_MAKE=""

# These are not intended to be user-specified
ARG _RESTY_CONFIG_DEPS="--with-pcre \
    --with-cc-opt='-DNGX_LUA_ABORT_AT_PANIC -I/usr/local/openresty/pcre2/include -I/usr/local/openresty/openssl3/include' \
    --with-ld-opt='-L/usr/local/openresty/pcre2/lib -L/usr/local/openresty/openssl3/lib -Wl,-rpath,/usr/local/openresty/pcre2/lib:/usr/local/openresty/openssl3/lib' \
    "

LABEL resty_image_base="${RESTY_IMAGE_BASE}"
LABEL resty_image_tag="${RESTY_IMAGE_TAG}"
LABEL resty_version="${RESTY_VERSION}"
LABEL resty_luarocks_version="${RESTY_LUAROCKS_VERSION}"
LABEL resty_openssl_version="${RESTY_OPENSSL_VERSION}"
LABEL resty_openssl_url_base="${RESTY_OPENSSL_URL_BASE}"
LABEL resty_openssl_build_options="${RESTY_OPENSSL_BUILD_OPTIONS}"
LABEL resty_pcre_version="${RESTY_PCRE_VERSION}"
LABEL resty_pcre_build_options="${RESTY_PCRE_BUILD_OPTIONS}"
LABEL resty_pcre_sha256="${RESTY_PCRE_SHA256}"
LABEL resty_config_options="${RESTY_CONFIG_OPTIONS}"
LABEL resty_config_options_more="${RESTY_CONFIG_OPTIONS_MORE}"
LABEL resty_config_deps="${_RESTY_CONFIG_DEPS}"
LABEL resty_add_package_builddeps="${RESTY_ADD_PACKAGE_BUILDDEPS}"
LABEL resty_add_package_rundeps="${RESTY_ADD_PACKAGE_RUNDEPS}"
LABEL resty_eval_pre_configure="${RESTY_EVAL_PRE_CONFIGURE}"
LABEL resty_eval_post_download_pre_configure="${RESTY_EVAL_POST_DOWNLOAD_PRE_CONFIGURE}"
LABEL resty_eval_pre_make="${RESTY_EVAL_PRE_MAKE}"
LABEL resty_eval_post_make="${RESTY_EVAL_POST_MAKE}"
LABEL resty_luajit_options="${RESTY_LUAJIT_OPTIONS}"
LABEL resty_pcre_options="${RESTY_PCRE_OPTIONS}"

# Copy helper scripts
COPY tmp /tmp

# ===== Stage 1: Install system dependencies =====
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        gettext-base \
        libgd-dev \
        libgeoip-dev \
        libncurses5-dev \
        libperl-dev \
        libreadline-dev \
        libxslt1-dev \
        make \
        perl \
        unzip \
        wget \
        zlib1g-dev \
        git \
        ${RESTY_ADD_PACKAGE_BUILDDEPS} \
        ${RESTY_ADD_PACKAGE_RUNDEPS} \
    && cd /tmp \
    && if [ -f /tmp/pre.sh ]; then bash /tmp/pre.sh; fi \
    && if [ -n "${RESTY_EVAL_PRE_CONFIGURE}" ]; then eval $(echo ${RESTY_EVAL_PRE_CONFIGURE}); fi

# ===== Stage 2: Download and build Tongsuo (铜锁) =====
RUN set -ex \
    && echo '=== Downloading and building Tongsuo (铜锁) ===' \
    && cd /tmp \
    && curl -fSL "${RESTY_OPENSSL_URL_BASE}/${RESTY_OPENSSL_VERSION}.tar.gz" \
         -o tongsuo-${RESTY_OPENSSL_VERSION}.tar.gz \
    && ls -la tongsuo-${RESTY_OPENSSL_VERSION}.tar.gz \
    && tar xzf tongsuo-${RESTY_OPENSSL_VERSION}.tar.gz \
    && ls -d Tongsuo-* \
    && mv Tongsuo-${RESTY_OPENSSL_VERSION} openssl-${RESTY_OPENSSL_VERSION} \
    && cd openssl-${RESTY_OPENSSL_VERSION} \
    && echo '=== Configuring Tongsuo ===' \
    && ./config \
      shared zlib -g \
      --prefix=/usr/local/openresty/openssl3 \
      --libdir=lib \
      -Wl,-rpath,/usr/local/openresty/openssl3/lib \
      ${RESTY_OPENSSL_BUILD_OPTIONS} \
    && echo '=== Building Tongsuo ===' \
    && make -j${RESTY_J} \
    && echo '=== Installing Tongsuo ===' \
    && make -j${RESTY_J} install_sw \
    && echo '=== Cleaning up Tongsuo sources ===' \
    && rm -f /tmp/tongsuo-${RESTY_OPENSSL_VERSION}.tar.gz \
    && rm -rf /tmp/openssl-${RESTY_OPENSSL_VERSION}

# ===== Stage 3: Download and build PCRE2 =====
RUN echo '=== Downloading and building PCRE2 ===' \
    && cd /tmp \
    && curl -fSL "https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${RESTY_PCRE_VERSION}/pcre2-${RESTY_PCRE_VERSION}.tar.gz" \
         -o pcre2-${RESTY_PCRE_VERSION}.tar.gz \
    && echo "${RESTY_PCRE_SHA256}  pcre2-${RESTY_PCRE_VERSION}.tar.gz" | shasum -a 256 --check \
    && tar xzf pcre2-${RESTY_PCRE_VERSION}.tar.gz \
    && cd /tmp/pcre2-${RESTY_PCRE_VERSION} \
    && CFLAGS="-g -O3" ./configure \
        --prefix=/usr/local/openresty/pcre2 \
        --libdir=/usr/local/openresty/pcre2/lib \
        ${RESTY_PCRE_BUILD_OPTIONS} \
    && CFLAGS="-g -O3" make -j${RESTY_J} \
    && CFLAGS="-g -O3" make -j${RESTY_J} install \
    && rm -f /tmp/pcre2-${RESTY_PCRE_VERSION}.tar.gz \
    && rm -rf /tmp/pcre2-${RESTY_PCRE_VERSION}

# ===== Stage 4: Download and build OpenResty =====
RUN echo '=== Downloading and building OpenResty ===' \
    && cd /tmp \
    && curl -fSL "https://openresty.org/download/openresty-${RESTY_VERSION}.tar.gz" \
         -o openresty-${RESTY_VERSION}.tar.gz \
    && if [ ! -d openresty-${RESTY_VERSION} ]; then tar xzf openresty-${RESTY_VERSION}.tar.gz; fi \
    && cd /tmp/openresty-${RESTY_VERSION} \
    && if [ -n "${RESTY_EVAL_POST_DOWNLOAD_PRE_CONFIGURE}" ]; then eval $(echo ${RESTY_EVAL_POST_DOWNLOAD_PRE_CONFIGURE}); fi \
    && eval ./configure -j${RESTY_J} ${_RESTY_CONFIG_DEPS} ${RESTY_CONFIG_OPTIONS} ${RESTY_CONFIG_OPTIONS_MORE} ${RESTY_LUAJIT_OPTIONS} ${RESTY_PCRE_OPTIONS} \
    && if [ -n "${RESTY_EVAL_PRE_MAKE}" ]; then eval $(echo ${RESTY_EVAL_PRE_MAKE}); fi \
    && make -j${RESTY_J} \
    && make -j${RESTY_J} install \
    && rm -f /tmp/openresty-${RESTY_VERSION}.tar.gz \
    && rm -rf /tmp/openresty-${RESTY_VERSION}

# ===== Stage 5: Build LuaRocks =====
RUN echo '=== Downloading and building LuaRocks ===' \
    && cd /tmp \
    && curl -fSL "https://luarocks.github.io/luarocks/releases/luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz" \
         -o luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz \
    && tar xzf luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz \
    && cd luarocks-${RESTY_LUAROCKS_VERSION} \
    && ./configure \
        --prefix=/usr/local/openresty/luajit \
        --with-lua=/usr/local/openresty/luajit \
        --with-lua-include=/usr/local/openresty/luajit/include/luajit-2.1 \
    && make build \
    && make install \
    && cd /tmp \
    && if [ -n "${RESTY_EVAL_POST_MAKE}" ]; then eval $(echo ${RESTY_EVAL_POST_MAKE}); fi \
    && rm -rf luarocks-${RESTY_LUAROCKS_VERSION} luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz

# ===== Stage 6: Final cleanup =====
RUN if [ -n "${RESTY_ADD_PACKAGE_BUILDDEPS}" ]; then DEBIAN_FRONTEND=noninteractive apt-get remove -y --purge ${RESTY_ADD_PACKAGE_BUILDDEPS} ; fi \
    && DEBIAN_FRONTEND=noninteractive apt-get autoremove -y \
    && mkdir -p /var/run/openresty \
    && ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log \
    && ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log

# Add additional binaries into PATH for convenience
ENV PATH=$PATH:/usr/local/openresty/luajit/bin:/usr/local/openresty/nginx/sbin:/usr/local/openresty/bin

# Add LuaRocks paths
# If OpenResty changes, these may need updating:
#    /usr/local/openresty/bin/resty -e 'print(package.path)'
#    /usr/local/openresty/bin/resty -e 'print(package.cpath)'
ENV LUA_PATH="/usr/local/openresty/site/lualib/?.ljbc;/usr/local/openresty/site/lualib/?/init.ljbc;/usr/local/openresty/lualib/?.ljbc;/usr/local/openresty/lualib/?/init.ljbc;/usr/local/openresty/site/lualib/?.lua;/usr/local/openresty/site/lualib/?/init.lua;/usr/local/openresty/lualib/?.lua;/usr/local/openresty/lualib/?/init.lua;./?.lua;/usr/local/openresty/luajit/share/luajit-2.1/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;/usr/local/openresty/luajit/share/lua/5.1/?.lua;/usr/local/openresty/luajit/share/lua/5.1/?/init.lua"

ENV LUA_CPATH="/usr/local/openresty/site/lualib/?.so;/usr/local/openresty/lualib/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/openresty/luajit/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so;/usr/local/openresty/luajit/lib/lua/5.1/?.so"

# Copy nginx configuration files
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf

# Run post-install script if exists
RUN if [ -f /tmp/default.sh ]; then bash /tmp/default.sh; fi

# Verify Tongsuo build
RUN /usr/local/openresty/openssl3/bin/openssl version \
    && echo "=== SM2 curve check ===" \
    && /usr/local/openresty/openssl3/bin/openssl ecparam -list_curves 2>&1 | grep -i sm2 || echo "SM2 check via: openssl ecparam -list_curves" \
    && echo "=== OpenResty built with ===" \
    && /usr/local/openresty/nginx/sbin/nginx -V 2>&1 | grep -i "built with"

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]

# Use SIGQUIT instead of default SIGTERM to cleanly drain requests
STOPSIGNAL SIGQUIT
