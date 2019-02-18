FROM ubuntu:latest

WORKDIR /root

COPY b-log/b-log.sh /tmp
COPY config.sh /tmp

RUN bash /tmp/config.sh

CMD /bin/bash