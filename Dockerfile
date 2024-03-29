# ARCH= && docker build -t netcan/debian${ARCH:+:$ARCH} --build-arg ARCH=${ARCH:+$ARCH/} .
ARG ARCH=
FROM ${ARCH}debian:unstable
ENV TZ="Asia/Shanghai"

RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates

COPY sources.list /etc/apt/sources.list

RUN apt-get update && apt-get upgrade -y

# system tools
RUN apt-get update && \
    apt-get install -y \
    openssh-server sudo locales \
    tmux proxychains4 net-tools bash-completion iputils-ping dnsutils traceroute \
    netcat-traditional telnet nmap man fdisk \ 
    lsb-release wget software-properties-common gpg lz4

RUN (sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen) && locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# vim
RUN apt-get update && \
    apt-get install -y \
    neovim \
    python-is-python3 \
    python3-pip \
    python3-distutils \
    python3-neovim

# dev tools
RUN apt-get update && \
    apt-get install -y \
    bc \
    build-essential \
    bzip2 \
    cpio \
    curl \
    file \
    flex \
    g++ \
    gawk \
    gcc \
    gdb \
    valgrind \
    gettext \
    git \
    htop \
    libdata-dumper-simple-perl \
    libncurses5-dev \
    libssl-dev \
    make \
    patch \
    rsync \
    ripgrep \
    unzip \
    zlib1g-dev \
    cmake \
    ninja-build \
    linux-perf \
    libcurl4-openssl-dev

# llvm
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
RUN add-apt-repository 'deb http://apt.llvm.org/unstable/ llvm-toolchain main'
RUN apt-get update && \
    apt-get install -y \
    clang-format clang-tidy clang-tools clang clangd libc++-dev libc++1\
    libc++abi-dev libc++abi1 libclang-dev libclang1 liblldb-dev libllvm-ocaml-dev\
    libomp-dev libomp5 lld llvm-dev llvm-runtime llvm python3-clang

# node
RUN wget -O - https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo apt-key add -
RUN add-apt-repository 'deb https://deb.nodesource.com/node_21.x nodistro main'
RUN apt-get install -y nodejs

# add netcan workdir
ENV HOME=/home/netcan
RUN useradd -ms /bin/bash netcan && (echo "netcan: " | chpasswd)
RUN echo "netcan ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/netcan && chmod 0440 /etc/sudoers.d/netcan

USER netcan
WORKDIR $HOME
RUN pip install --break-system-packages --user jedi cmake-language-server

# tmux
RUN git clone https://github.com/jimeh/tmux-themepack.git ~/.tmux-themepack
COPY --chown=netcan .tmux.conf $HOME/

# autojump
RUN sudo apt-get install -y autojump && echo ". /usr/share/autojump/autojump.sh" >> ~/.bashrc

# fzf
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && yes y | ~/.fzf/install

# vim
RUN sudo npm install -g neovim
COPY --chown=netcan .config $HOME/.config
RUN curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
    vim +PlugInstall +qall

# proxychains
RUN sudo sed -i '/^socks/s/.*/socks5 192.168.124.7 1080/g' /etc/proxychains4.conf

# cleanup
RUN sudo apt-get autoremove -y && sudo apt-get clean

EXPOSE 22

CMD sudo chown -f netcan /mnt/*; \
    sudo service ssh start; \
    bash
