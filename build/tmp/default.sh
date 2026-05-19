#!/bin/bash
# default.sh — Post-install setup script for OpenResty + Tongsuo
apt-get install -y --no-install-recommends libsqlite3-dev git python3 automake autoconf libtool \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /usr/local/openresty/1pwaf/libraries
echo "[default.sh] Post-install setup complete."
