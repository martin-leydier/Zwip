FROM crystallang/crystal:1.3.2-alpine AS build

WORKDIR /build
# mailcap provides mime types db
RUN apk add mailcap

COPY . /zwip
WORKDIR /zwip
RUN make release_static && strip -s /zwip/bin/Zwip

FROM scratch

USER 12345:12345
ENV KEMAL_ENV=production
VOLUME ["/var/www"]
EXPOSE 3000/tcp
ENTRYPOINT ["/Zwip"]
CMD [ "-c", "/config.json"]
HEALTHCHECK --timeout=5s ["CMD", "/Zwip", "-h", "3000"]

COPY --from=build /etc/mime.types /etc/mime.types
COPY --from=build /zwip/config.json /config.json
COPY --from=build /zwip/bin/Zwip /Zwip
