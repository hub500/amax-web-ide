FROM ubuntu:18.04
RUN [ -z "$(apt-get indextargets)" ]
RUN set -xe  \
        && echo '#!/bin/sh' > /usr/sbin/policy-rc.d  \
        && echo 'exit 101' >> /usr/sbin/policy-rc.d  \
        && chmod +x /usr/sbin/policy-rc.d  \
        && dpkg-divert --local --rename --add /sbin/initctl  \
        && cp -a /usr/sbin/policy-rc.d /sbin/initctl  \
        && sed -i 's/^exit.*/exit 0/' /sbin/initctl  \
        && echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup  \
        && echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean  \
        && echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean  \
        && echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean  \
        && echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages  \
        && echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes  \
        && echo 'Apt::AutoRemove::SuggestsImportant "false";' > /etc/apt/apt.conf.d/docker-autoremove-suggests
RUN mkdir -p /run/systemd  \
        && echo 'docker' > /run/systemd/container
CMD ["/bin/bash"]
RUN yes | unminimize  \
        && apt-get update  \
        && apt-get install -yq asciidoctor bash-completion build-essential clang-tools-8 curl g++-8 git htop jq less libcurl4-gnutls-dev libgmp3-dev libssl-dev libusb-1.0-0-dev llvm-7-dev locales man-db multitail nano nginx ninja-build pkg-config python software-properties-common sudo supervisor vim wget xz-utils zlib1g-dev  \
        && update-alternatives --remove-all cc  \
        && update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-8 100  \
        && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 100  \
        && update-alternatives --remove-all c++  \
        && update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-8 100  \
        && update-alternatives --install /usr/bin/gcc++ gcc++ /usr/bin/g++-8 100  \
        && update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-8 100  \
        && mkdir build  \
        && cd /home/gitpod/eos/build  \
        && cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr ..  \
        && ninja  \
        && sudo ninja install  \
        && sudo ln -s /usr/lib/x86_64-linux-gnu/cmake/eosio/ /usr/lib/cmake/eosio  \
        && cd /home/gitpod  \
        && mv /home/gitpod/eos/build/unittests/contracts /home/gitpod/contracts  \
        && rm -rf /home/gitpod/eos  \
        && mkdir -p /home/gitpod/eos/build/unittests/  \
        && mv /home/gitpod/contracts /home/gitpod/eos/build/unittests/
USER root
WORKDIR /root
RUN apt-get update  \
        && wget https://github.com/EOSIO/eosio.cdt/releases/download/v1.7.0/eosio.cdt_1.7.0-1-ubuntu-18.04_amd64.deb  \
        && apt-get install -y ./eosio.cdt_1.7.0-1-ubuntu-18.04_amd64.deb  \
        && rm -rf *.deb /var/lib/apt/lists/*  \
        && apt-get clean  \
        && rm -rf /var/lib/apt/lists/* /tmp/*
WORKDIR /home/gitpod/
USER gitpod
RUN git clone https://github.com/EOSIO/eosio.contracts.git  \
        && cd /home/gitpod/eosio.contracts  \
        && git checkout release/1.9.x  \
        && git submodule update --init --recursive  \
        && mkdir build  \
        && cd /home/gitpod/eosio.contracts/build  \
        && cmake -GNinja ..  \
        && ninja  \
        && mkdir /home/gitpod/contracts  \
        && cp `find . -name 'eosio.*.wasm'` /home/gitpod/contracts  \
        && cd /home/gitpod  \
        && rm -rf /home/gitpod/eosio.contracts
USER root
WORKDIR /root
RUN echo >/password  \
        && chown gitpod /password  \
        && chgrp gitpod /password  \
        && >/run/nginx.pid  \
        && chmod 666 /run/nginx.pid  \
        && chmod 666 /var/log/nginx/*  \
        && chmod 777 /var/lib/nginx /var/log/nginx
WORKDIR /home/gitpod
USER gitpod
RUN { echo  \
        && echo "PS1='\[\e]0;\u \w\a\]\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \\\$ '" ; } >> .bashrc
RUN sudo echo "Running 'sudo' for Gitpod: success"
RUN cleos wallet create --to-console | tail -n 1 | sed 's/"//g' >/password  \
        && cleos wallet import --private-key 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3
RUN echo '\n unlock-timeout = 31536000 \n' >$HOME/eosio-wallet/config.ini
RUN rm -f $HOME/.wget-hsts
WORKDIR /home/gitpod
USER gitpod
RUN notOwnedFile=$(find . -not "(" -user gitpod -and -group gitpod ")" -print -quit)  \
        && { [ -z "$notOwnedFile" ] || { echo "Error: not all files/dirs in $HOME are owned by 'gitpod' user & group"; exit 1; } }
