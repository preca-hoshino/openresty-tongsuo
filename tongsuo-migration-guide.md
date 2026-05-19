# 铜锁(Tongsuo)替换 OpenResty OpenSSL 方案

> **目标**：将 1Panel OpenResty Dockerfile 中的 OpenSSL 3.5.6 替换为铜锁 8.5.x，
> 实现国密 SM2/SM3/SM4/TLCP/NTLS 全栈支持，同时保持原国际 HTTPS 100% 兼容。

---

## 一、核心变化

| 组件 | 原版 | 替换后 |
|------|------|--------|
| 底层密码库 | OpenSSL 3.5.6 | 铜锁 8.5.0-pre1 (基于 OpenSSL 3.5.4) |
| 国密算法 | ❌ 不支持 | ✅ SM2/SM3/SM4/祖冲之 |
| 国密 TLS | ❌ 不支持 | ✅ TLCP (GB/T 38636) + NTLS 双证书 |
| 国密 TLS 1.3 | ❌ 不支持 | ✅ RFC 8998 单证书模式 |
| 国际算法 | ✅ | ✅ 完全保留 |
| FIPS | ✅ OpenSSL FIPS 140 | ✅ GM/T 0028 国密局认证 |

---

## 二、Dockerfile 修改要点

### 2.1 版本和下载源

```dockerfile
# 原
ARG RESTY_OPENSSL_VERSION="3.5.6"
ARG RESTY_OPENSSL_PATCH_VERSION="3.5.5"
ARG RESTY_OPENSSL_URL_BASE="https://github.com/openssl/openssl/releases/download/openssl-${RESTY_OPENSSL_VERSION}"

# 改为
ARG RESTY_OPENSSL_VERSION="8.5.0-pre1"
ARG RESTY_OPENSSL_URL_BASE="https://github.com/Tongsuo-Project/Tongsuo/archive/refs/tags"
# ↑ 铜锁已内置 async session lookup，OpenResty 不需要额外补丁
```

### 2.2 编译选项

```dockerfile
# 原 (含已删除算法, 会报错)
ARG RESTY_OPENSSL_BUILD_OPTIONS="enable-camellia enable-seed enable-rfc3779 enable-cms \
  enable-md2 enable-rc5 enable-weak-ssl-ciphers enable-ssl3 enable-ssl3-method \
  enable-ktls enable-fips"

# 改为 (去掉铜锁已删除的算法, 增加国密)
ARG RESTY_OPENSSL_BUILD_OPTIONS="enable-ntls enable-rfc3779 enable-cms \
  enable-weak-ssl-ciphers enable-ssl3 enable-ssl3-method enable-ktls"
```

> 铜锁 8.4+ 已删除：Camellia, SEED, RC5, MD2, MD4, MDC2, IDEA, Blowfish, CAST, RIPEMD, 等

### 2.3 下载和编译过程

```dockerfile
# 原 (有 patch 步骤)
RUN curl -fSL "...openssl-${RESTY_OPENSSL_VERSION}.tar.gz" -o openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
    && tar xzf openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
    && cd openssl-${RESTY_OPENSSL_VERSION} \
    && patch -p1 < /tmp/openssl-${RESTY_OPENSSL_PATCH_VERSION}-sess_set_get_cb_yield.patch \
    && ./config ... \
    && make -j${RESTY_J} \
    && make -j${RESTY_J} install_sw

# 改为 (无需 patch, 目录名需要 mv 对齐)
RUN curl -fSL "${RESTY_OPENSSL_URL_BASE}/Tongsuo-${RESTY_OPENSSL_VERSION}.tar.gz" \
         -o Tongsuo-${RESTY_OPENSSL_VERSION}.tar.gz \
    && tar xzf Tongsuo-${RESTY_OPENSSL_VERSION}.tar.gz \
    && mv Tongsuo-${RESTY_OPENSSL_VERSION} openssl-${RESTY_OPENSSL_VERSION} \
    && cd openssl-${RESTY_OPENSSL_VERSION} \
    && ./config \
       shared zlib -g \
       --prefix=/usr/local/openresty/openssl3 \
       --libdir=lib \
       -Wl,-rpath,/usr/local/openresty/openssl3/lib \
       ${RESTY_OPENSSL_BUILD_OPTIONS} \
    && make -j${RESTY_J} \
    && make -j${RESTY_J} install_sw
```

其余部分（PCRE2, LuaJIT, OpenResty configure, luarocks, 1pwaf）**完全不动**。

---

## 三、Nginx 配置

### 3.1 国际 HTTPS — 零改动

```nginx
server {
    listen 443 ssl;
    ssl_certificate     /etc/ssl/certs/ecc/server.crt;
    ssl_certificate_key /etc/ssl/certs/ecc/server.key;
    # ... 其余原样不变
}
```

铜锁完全兼容 OpenSSL API，标准指令一个字不用改。

### 3.2 国密 NTLS — 新增指令

```nginx
server {
    listen 443 ssl;

    # 国际证书 (保持原样)
    ssl_certificate     /etc/ssl/certs/ecc/server.crt;
    ssl_certificate_key /etc/ssl/certs/ecc/server.key;

    # 国密双证书 (铜锁特有, 新增)
    ssl_sign_certificate     /etc/ssl/certs/sm2/server-sign.crt;
    ssl_sign_certificate_key /etc/ssl/certs/sm2/server-sign.key;
    ssl_enc_certificate      /etc/ssl/certs/sm2/server-enc.crt;
    ssl_enc_certificate_key  /etc/ssl/certs/sm2/server-enc.key;

    # 同时启用国际+国密套件
    ssl_ciphers 'ECC-SM2-WITH-SM4-SM3:ECDHE-SM2-WITH-SM4-SM3:\
                 ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256';
    ssl_protocols TLSv1.2 TLSv1.3;
}
```

客户端自动协商：国密浏览器走 SM2+SM4+SM3，国际浏览器走 ECC/RSA+AES-GCM。

---

## 四、SM2 证书签发（配合你的 PKI）

使用已有 SM2 中间 CA 签发双证书：

```bash
# 1. 生成 SM2 私钥
openssl ecparam -genkey -name SM2 -out /etc/ssl/certs/sm2/domain.key

# 2. 生成 CSR
openssl req -new -key /etc/ssl/certs/sm2/domain.key \
  -out /etc/ssl/certs/sm2/domain.csr -sm3 \
  -subj "/C=CN/ST=Shanghai/L=Shanghai/O=Restart Game Lab/OU=ARTS CCIN SYSTEM/CN=domain.com"

# 3. 签名证书 (签名证书和加密证书可用同一 SM2 密钥对)
cd /docker/root-ca/intermediate/sm2-ssl
openssl ca -config openssl.cnf -extensions server_cert \
  -days 3650 -notext -md sm3 -batch \
  -in /etc/ssl/certs/sm2/domain.csr \
  -out /etc/ssl/certs/sm2/domain-sign.crt

# 4. 加密证书 (如果单独生成)
# 同样步骤生成另一份，CN 加 "-enc" 区分
# 或用同一份证书同时作为签名和加密证书 (SM2 设计上签名加密共用一个密钥对)
```

---

## 五、风险控制

| 检查项 | 状态 |
|--------|------|
| 原有 nginx.conf 标准指令 | ✅ 100% 兼容，无需修改 |
| 1pwaf / WAF / brotli | ✅ 不依赖密码库，无影响 |
| Lua/resty.core 扩展 | ✅ 通过 LuaJIT 调用，不直接链接 OpenSSL |
| HTTP/2, HTTP/3, WebSocket | ✅ 协议层不受底层密码库影响 |
| OpenSSL FIPS 依赖 | ✅ 铜锁有 GM/T 0028 认证，不启用则无影响 |
| OpenResty Lua SSL API | ✅ OpenSSL 1.1.1/3.x API 全兼容 |

---

## 六、验证步骤

```bash
# 1. 验证铜锁版本
/opt/tongsuo/bin/openssl version
# → "Tongsuo 8.5.0-pre1 (OpenSSL 3.5.4)"

# 2. 验证国密算法
/opt/tongsuo/bin/openssl ecparam -list_curves | grep SM2
/opt/tongsuo/bin/openssl enc -sm4-cbc -help

# 3. 验证 OpenResty 加载铜锁
/usr/local/openresty/nginx/sbin/nginx -V
# → "built with Tongsuo 8.5.0-pre1"

# 4. 测试国际 TLS 握手
openssl s_client -connect localhost:443 -tls1_3

# 5. 测试国密 TLCP 握手
/opt/tongsuo/bin/openssl s_client -connect localhost:443 \
  -enable_ntls -ntls_ciphers ECC-SM2-WITH-SM4-SM3
```

---

## 七、CI/CD 自动构建

### 7.1 GitHub Actions 工作流

本仓库包含一套完整的 GitHub Actions 工作流（`.github/workflows/docker-build.yml`），用于自动构建和发布镜像。

```bash
# 1. 创建新仓库并推送代码
git init
git add -A
git commit -m "feat: OpenResty + Tongsuo (铜锁) Docker image with CI/CD"
git remote add origin https://github.com/YOUR_USERNAME/openresty-tongsuo.git
git push -u origin main
```

### 7.2 触发方式

| 触发方式 | 说明 |
|---------|------|
| 推送到 main/master | 自动构建并推送镜像到 ghcr.io |
| PR 到 main/master | 构建但不推送（验证 Dockerfile 可构建） |
| workflow_dispatch | 手动触发，可指定版本号 |
| 定时 (每周一 6:00 UTC) | 自动重建以保持基础镜像更新 |

### 7.3 镜像标签

```
ghcr.io/YOUR_USERNAME/openresty-tongsuo:latest
ghcr.io/YOUR_USERNAME/openresty-tongsuo:openresty-1.29.2.4-tongsuo-8.5.0-pre1
ghcr.io/YOUR_USERNAME/openresty-tongsuo:sha-<commit-sha>
```

### 7.4 手动触发构建

1. 进入 GitHub 仓库 → Actions → "Build and Push OpenResty Tongsuo Docker Image"
2. 点击 "Run workflow"
3. 可选：指定 `tongsuo_version` 和 `openresty_version`
4. 点击 "Run workflow" 执行

### 7.5 拉取和使用

```bash
# 拉取镜像
docker pull ghcr.io/YOUR_USERNAME/openresty-tongsuo:latest

# 运行
docker run -d -p 80:80 -p 443:443 \
  --name openresty-tongsuo \
  ghcr.io/YOUR_USERNAME/openresty-tongsuo:latest
```

---

## 八、参考链接

- 铜锁 GitHub：https://github.com/Tongsuo-Project/Tongsuo
- 铜锁文档：https://www.tongsuo.net/docs
- RFC 8998（TLS 1.3 + 国密单证书）：https://datatracker.ietf.org/doc/html/rfc8998
- GB/T 38636-2020（TLCP 国密双证书协议）
- 1Panel OpenResty Dockerfile：`apps/openresty/1.29.2.4-0-noble/build/Dockerfile`
- 本项目仓库：`build/Dockerfile` + `.github/workflows/docker-build.yml`
