FROM debian:latest

RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates

COPY sources.list /etc/apt/sources.list

RUN apt-get update && apt-get upgrade -y

# system tools
RUN apt-get install -y \
    openssh-server \
    sudo \
    vim

# add netcan
RUN useradd -ms /bin/bash netcan
RUN echo "netcan ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/netcan && chmod 0440 /etc/sudoers.d/netcan

USER netcan
WORKDIR /home/netcan

CMD sudo service ssh start && \
    bash
