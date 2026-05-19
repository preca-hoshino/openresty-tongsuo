# OpenResty + Tongsuo (铜锁) Docker 镜像

> 🔐 **国密全栈 OpenResty**: SM2/SM3/SM4 + TLCP/NTLS + 国际 HTTPS 100% 兼容

基于 [1Panel OpenResty Dockerfile](https://github.com/1Panel-dev/appstore)，将 OpenSSL 3.5.6 替换为[铜锁 (Tongsuo) 8.5.0-pre1](https://github.com/Tongsuo-Project/Tongsuo)，实现国密算法全栈支持。

## 特性

| 特性 | 状态 |
|------|------|
| OpenResty 1.29.2.4 | ✅ |
| Tongsuo 8.5.0-pre1 (基于 OpenSSL 3.5.4) | ✅ |
| SM2/SM3/SM4 国密算法 | ✅ |
| TLCP (GB/T 38636) 双证书 | ✅ |
| NTLS 国密传输 | ✅ |
| RFC 8998 TLS 1.3 单证书 | ✅ |
| 国际 ECC/RSA + AES-GCM | ✅ |
| PCRE2 JIT | ✅ |
| LuaJIT + LuaRocks | ✅ |
| HTTP/2, HTTP/3, WebSocket | ✅ |

## 快速开始

### 从 GitHub Container Registry 拉取

```bash
docker pull ghcr.io/YOUR_USERNAME/openresty-tongsuo:latest
```

### 运行

```bash
docker run -d -p 80:80 -p 443:443 \
  --name openresty-tongsuo \
  ghcr.io/YOUR_USERNAME/openresty-tongsuo:latest
```

### 本地构建

```bash
docker build -t openresty-tongsuo ./build
```

自定义版本:

```bash
docker build \
  --build-arg RESTY_OPENSSL_VERSION=8.5.0-pre1 \
  --build-arg RESTY_VERSION=1.29.2.4 \
  --build-arg RESTY_J=$(nproc) \
  -t openresty-tongsuo \
  ./build
```

## 验证

```bash
# 1. 进入容器
docker exec -it openresty-tongsuo bash

# 2. 查看铜锁版本
/usr/local/openresty/openssl3/bin/openssl version
# → "Tongsuo 8.5.0-pre1 (OpenSSL 3.5.4)"

# 3. 验证国密算法
/usr/local/openresty/openssl3/bin/openssl ecparam -list_curves | grep SM2
echo "test" | /usr/local/openresty/openssl3/bin/openssl dgst -sm3

# 4. 查看 OpenResty 编译信息
/usr/local/openresty/nginx/sbin/nginx -V 2>&1
```

## Nginx 国密配置示例

```nginx
server {
    listen 443 ssl;

    # 国际证书 (标准 HTTPS)
    ssl_certificate     /etc/ssl/certs/ecc/server.crt;
    ssl_certificate_key /etc/ssl/certs/ecc/server.key;

    # 国密双证书 (铜锁特有)
    ssl_sign_certificate     /etc/ssl/certs/sm2/server-sign.crt;
    ssl_sign_certificate_key /etc/ssl/certs/sm2/server-sign.key;
    ssl_enc_certificate      /etc/ssl/certs/sm2/server-enc.crt;
    ssl_enc_certificate_key  /etc/ssl/certs/sm2/server-enc.key;

    # 混合加密套件
    ssl_ciphers 'ECC-SM2-WITH-SM4-SM3:ECDHE-SM2-WITH-SM4-SM3:\
                 ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256';
    ssl_protocols TLSv1.2 TLSv1.3;
}
```

## CI/CD

本仓库使用 GitHub Actions 自动构建和推送镜像到 GitHub Container Registry。

- **自动触发**: 推送到 `main` 分支
- **手动触发**: Actions → "Build and Push OpenResty Tongsuo Docker Image" → Run workflow
- **定时构建**: 每周一 6:00 UTC (保持基础镜像更新)
- **PR 检查**: PR 会构建但不推送 (验证 Dockerfile 可构建)

## 项目结构

```
.
├── .github/workflows/
│   └── docker-build.yml       # CI/CD 工作流
├── build/
│   ├── Dockerfile             # 镜像构建文件
│   ├── nginx.conf             # OpenResty 主配置
│   ├── nginx.vh.default.conf  # 默认虚拟主机
│   └── tmp/
│       ├── pre.sh             # 构建前脚本
│       └── default.sh         # 构建后脚本
├── tongsuo-migration-guide.md # 迁移指南
└── README.md
```

## 与传统 OpenSSL 版的区别

| 组件 | 原版 | 铜锁版 |
|------|------|--------|
| 密码库 | OpenSSL 3.5.6 | Tongsuo 8.5.0-pre1 |
| 国密支持 | ❌ | ✅ SM2/SM3/SM4 |
| async session lookup 补丁 | 需要 patch | 内置 |
| Camellia/SEED/RC5/MD2 | 可选 | 已删除 |
| FIPS | OpenSSL FIPS 140 | GM/T 0028 国密局认证 |

## 参考

- [铜锁 GitHub](https://github.com/Tongsuo-Project/Tongsuo)
- [铜锁文档](https://www.tongsuo.net/docs)
- [RFC 8998 - TLS 1.3 + 国密](https://datatracker.ietf.org/doc/html/rfc8998)
- [GB/T 38636-2020 - TLCP 协议](https://std.samr.gov.cn/gb/search/gbDetailed?id=71D5A5E5F5C5B5C5E5F5C5B5C5E5F5C5)
- [1Panel OpenResty Dockerfile](https://github.com/1Panel-dev/appstore/tree/dev/apps/openresty)

## 许可证

本项目基于原始 OpenResty Docker 镜像修改，遵循相应的开源许可协议。
