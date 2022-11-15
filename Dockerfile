FROM debian:testing

RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates

COPY sources.list /etc/apt/sources.list

RUN apt-get update && apt-get upgrade -y

# system tools
RUN apt-get install -y \
    openssh-server sudo locales \
    tmux proxychains4 net-tools

RUN (sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen) && locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# vim
RUN apt-get install -y \
    neovim \
    python2 \
    python3-distutils \
    python3-neovim

# dev tools
RUN apt-get install -y \
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
    htop \
    libdata-dumper-simple-perl \
    libncurses5-dev \
    libssl-dev \
    make \
    patch \
    rsync \
    unzip \
    zlib1g-dev \
    wget

# shell
RUN apt-get install -y zsh autojump
# add netcan workdir
ENV HOME=/home/netcan
RUN useradd -ms /usr/bin/zsh netcan && (echo "netcan: " | chpasswd)
RUN echo "netcan ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/netcan && chmod 0440 /etc/sudoers.d/netcan
USER netcan
WORKDIR $HOME
RUN yes | sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# fzf
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && yes y | ~/.fzf/install

# cleanup
RUN sudo apt-get clean

COPY --chown=netcan .zshrc $HOME/

EXPOSE 22

CMD sudo service ssh start && \
    zsh
