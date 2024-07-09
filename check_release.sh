#!/bin/bash
set -eu

CURRENT_PATH=$(pwd)

git clone https://github.com/nginx/nginx.git
git clone https://github.com/openssl/openssl.git
git clone https://github.com/chobits/ngx_http_proxy_connect_module.git
git clone https://github.com/aericpp/nginx-proxy.git

# check nginx version
cd "$CURRENT_PATH/nginx"
NGINX_VERSION=$(test -f .hgtags && cat .hgtags |tail -n 1 |awk '{print $2}')
echo $NGINX_VERSION > "$CURRENT_PATH/nginx.version"
NGINX_VERSION_NUMBER=$(echo $NGINX_VERSION| cut -c9-)
echo $NGINX_VERSION_NUMBER > "$CURRENT_PATH/nginx.version.number"
git checkout $NGINX_VERSION

# check nginx version
cd "$CURRENT_PATH/openssl"
OPENSSL_VERSION=$(git log --simplify-by-decoration --pretty="format:%ct %D" --tags \
    | grep openssl-3. \
    | sort -k 2 -t ":" -r \
    | head -n 1 \
    | awk '{print $3}')
git checkout $OPENSSL_VERSION
echo $OPENSSL_VERSION > "$CURRENT_PATH/openssl.version"

# check release
cd "$CURRENT_PATH/nginx-proxy"
TAG_NAME=$(echo "v${NGINX_VERSION_NUMBER}-${OPENSSL_VERSION}")
TAG_EXIST=$(git tag -l ${TAG_NAME})

echo $TAG_NAME > "$CURRENT_PATH/release.version"
echo $TAG_EXIST > "$CURRENT_PATH/tag.exist"

if [ "$TAG_NAME" == "$TAG_EXIST" ]; then
  echo 0
else
  echo 1
fi