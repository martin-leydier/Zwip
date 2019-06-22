FROM crystallang/crystal:0.29.0

RUN apt-get update && \
    apt-get install -y zip && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME ["/var/www/"]
EXPOSE 3000/tcp
WORKDIR /zwip
ARG ROOT=/var/www
ENV ROOT=$ROOT

ADD . /zwip
RUN make release

CMD ["bin/Zwip"]
