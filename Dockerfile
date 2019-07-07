# Dependencies
FROM gcc:9 AS deps_build

WORKDIR /build
# compile su-exec, linked statically
RUN git clone https://github.com/ncopa/su-exec.git && \
    cd su-exec && \
    make su-exec-static && \
# compile zip(1), linked statically
    cd /build && \
    wget ftp://ftp.info-zip.org/pub/infozip/src/zip30.tgz && \
    tar xf zip30.tgz && \
    cd zip30 && \
# force staticy link flag, yes by changing the C compiler, it's the most horrendous thing ever made, but it works, even when the makefile is a bit weird
    make CC="gcc -static -s" -f unix/Makefile generic


# App build
FROM alpine:3.10 AS cr_build

COPY . /zwip
WORKDIR /zwip
# mailcap provides mime types
RUN apk add crystal shards mailcap && \
    apk add --virtual build-dependencies zlib-dev openssl-dev build-base gcc && \
    make release_static


# Final container
FROM scratch

VOLUME ["/var/www/"]
EXPOSE 3000/tcp
ENV UID=1014 GID=1014 PATH="/sbin" ROOT="/var/www/" KEMAL_ENV=production

COPY --from=deps_build /build/su-exec/su-exec-static /sbin/su-exec
COPY --from=deps_build /build/zip30/zip /sbin/zip
COPY busybox /bin/busybox
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/busybox", "sh", "/entrypoint.sh"]

COPY --from=cr_build /zwip/bin/Zwip /Zwip
COPY --from=cr_build /etc/mime.types /etc/mime.types
COPY --from=cr_build /zwip/public /public

CMD ["/Zwip"]
