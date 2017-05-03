#!/bin/bash
set -e

rm -rf output
mkdir -p ./output
docker run -i --rm -v "$(pwd)/output":/output golang:1.8-alpine /bin/sh <<-EOF
apk --update add perl git curl bash ca-certificates
curl -s https://raw.githubusercontent.com/pote/gpm/v1.4.0/bin/gpm > /bin/gpm
chmod +x /bin/gpm
curl -LO https://raw.githubusercontent.com/curl/curl/master/lib/mk-ca-bundle.pl
mkdir -p /output/etc/ssl/certs/
perl ./mk-ca-bundle.pl /output/etc/ssl/certs/ca-certificates.crt
mkdir -p "\$GOPATH"/src/github.com/bitly/oauth2_proxy
git clone --branch v2.2 https://github.com/bitly/oauth2_proxy "\$GOPATH"/src/github.com/bitly/oauth2_proxy
cd "\$GOPATH"/src/github.com/bitly/oauth2_proxy
gpm install
go vet ./...
go test ./...
CGO_ENABLED=0 go build --ldflags "-s -w -extldflags '-static'" -o /output/oauth2_proxy .
EOF

docker run --rm -v "$(pwd):/data" lalyos/upx --best --ultra-brute output/oauth2_proxy

docker build -t quay.io/cehoffman/oauth2_proxy:$(git rev-parse HEAD) .
