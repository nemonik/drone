FROM golang:1.14.4-alpine as builder
WORKDIR /build
RUN apk add --no-cache alpine-sdk && \
    git -c http.sslVerify=false clone https://github.com/drone/drone.git && \
    cd drone && \
    export TAG=$(git describe --tags $(git rev-list --tags --max-count=1)) && \
    git checkout tags/$TAG -b $TAG && \
    go build -tags "nolimit" ./cmd/drone-server

FROM alpine
MAINTAINER Michael Joseph Walsh <github.com@nemonik.com>

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV GODEBUG netdns=go
ENV XDG_CACHE_HOME /data
ENV DRONE_SERVER_PORT :80
ENV DRONE_RUNNER_OS linux
ENV DRONE_RUNNER_ARCH amd64
ENV DRONE_SERVER_HOST localhost
ENV DRONE_DATABASE_DRIVER sqlite3
ENV DRONE_DATABASE_DATASOURCE /data/database.sqlite
ENV DRONE_DATADOG_ENABLED true
ENV DRONE_DATADOG_ENDPOINT https://stats.drone.ci/api/v1/series

COPY --from=builder /build/drone/drone-server /bin/

RUN apk add --no-cache sqlite sqlite-dev zip && \
    mkdir /data

EXPOSE 80
VOLUME ["/data"]
ENTRYPOINT ["/bin/drone-server"]
