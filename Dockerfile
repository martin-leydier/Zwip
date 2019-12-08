# App build
FROM alpine:edge AS build

WORKDIR /build
# compile su-exec, linked statically
# mailcap provides mime types
RUN apk add gcc musl-dev git zlib-static zlib-dev openssl-libs-static openssl-dev build-base wget libevent libevent-dev libevent-static yaml-dev crystal shards mailcap && \
    git clone --depth 1 https://github.com/ncopa/su-exec.git && \
    cd su-exec && \
    make su-exec-static && \
# compile zip(1), linked statically
    cd /build && \
    wget ftp://ftp.info-zip.org/pub/infozip/src/zip30.tgz && \
    tar xf zip30.tgz && \
    cd zip30 && \
# force staticy link flag, yes by changing the C compiler, it's the most horrendous thing ever made, but it works, even when the makefile is a bit weird
    make CC="gcc -static -s" -f unix/Makefile generic

COPY . /zwip
WORKDIR /zwip
RUN make release_static

# Final container
FROM scratch

EXPOSE 3000/tcp
ENV UID=1014 GID=1014 PATH="/sbin" ROOT="/var/www/" KEMAL_ENV=production

COPY busybox /bin/busybox
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/busybox", "sh", "/entrypoint.sh"]

COPY --from=build /build/su-exec/su-exec-static /sbin/su-exec
COPY --from=build /build/zip30/zip /sbin/zip
COPY --from=build /zwip/bin/Zwip /Zwip
COPY --from=build /zwip/config.json /config.json
COPY --from=build /etc/mime.types /etc/mime.types

VOLUME ["/var/www"]

CMD ["/Zwip"]
