FROM crystallang/crystal:0.28.0

RUN apt-get update && \
    apt-get install -y zip && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME ["/var/www/"]
EXPOSE 3000/tcp

ADD . /zwip
WORKDIR /zwip
RUN make release

ENTRYPOINT ["bin/Zwip"]
