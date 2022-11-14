FROM debian:latest

RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates

COPY sources.list /etc/apt/sources.list

RUN apt-get update && apt-get upgrade -y

# system tools
RUN apt-get install -y \
    openssh-server sudo bash-completion locales \
    tmux proxychains4 net-tools

RUN (sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen) && locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# dev tools
RUN apt-get update && apt-get install -y \
        bc \
        build-essential \
        bzip2 \
        clang \
        cpio \
        curl \
        file \
        flex \
        g++ \
        gawk \
        gcc \
        gettext \
        git \
        libdata-dumper-simple-perl \
        libncurses5-dev \
        libssl-dev \
        make \
        neovim \
        patch \
        python \
        python3-distutils \
        python3-neovim \
        rsync \
        unzip \
        zlib1g-dev \
        wget \

RUN apt-get clean

# add netcan
RUN useradd -ms /bin/bash netcan && (echo "netcan: " | chpasswd)
RUN echo "netcan ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/netcan && chmod 0440 /etc/sudoers.d/netcan

USER netcan
WORKDIR /home/netcan

EXPOSE 22

CMD sudo service ssh start && \
    bash
