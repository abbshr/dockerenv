FROM ubuntu:latest

WORKDIR /root

COPY config.sh /root
RUN bash /root/config.sh

CMD /bin/bash