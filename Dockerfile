FROM armoniax/amnod:0.5.0
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
	&& locale-gen en_US.UTF-8  \
	&& curl -sL https://deb.nodesource.com/setup_10.x | bash -  \
	&& apt-get install -yq nodejs  \
	&& apt-get clean  \
	&& rm -rf /var/lib/apt/lists/* /tmp/*  \
	&& npm i -g yarn typescript
ENV LANG=en_US.UTF-8
WORKDIR /root
RUN curl -LO https://cmake.org/files/v3.13/cmake-3.13.2.tar.gz  \
	&& tar -xzf cmake-3.13.2.tar.gz  \
	&& cd cmake-3.13.2  \
	&& ./bootstrap --prefix=/usr/local  \
	&& make -j$(nproc)  \
	&& make install  \
	&& cd /root  \
	&& rm -rf cmake-3.13.2.tar.gz cmake-3.13.2
RUN curl -LO https://boostorg.jfrog.io/artifactory/main/release/1.72.0/source/boost_1_72_0.tar.bz2  \
	&& tar -xjf boost_1_72_0.tar.bz2  \
	&& cd boost_1_72_0  \
	&& ./bootstrap.sh --prefix=/usr/local  \
	&& ./b2 --with-iostreams --with-date_time --with-filesystem --with-system --with-program_options --with-chrono --with-test -j$(nproc) install  \
	&& cd /root  \
	&& rm -rf boost_1_72_0.tar.bz2 boost_1_71_0
RUN useradd -l -u 33333 -G sudo -md /home/gitpod -s /bin/bash -p gitpod gitpod  \
	&& sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers



USER root
WORKDIR /root
RUN apt-get update  \
        && git clone https://github.com/armoniax/amax.cdt.git  \
        && cd amax.cdt  \
        && git submodule update --init --recursive  \
        && mkdir build \
        && cd build \
        && cmake .. \
        && make -j8

USER root
WORKDIR /root/amax.cdt/build
RUN make install

WORKDIR /home/gitpod/
USER gitpod
# RUN  git clone https://github.com/armoniax/amax.contracts \
#         && cd /home/gitpod/amax.contracts  \
#         && git submodule update --init --recursive  \
#         && cd src_system  \
#         && bash ./build.sh -y \
#         && mkdir /home/gitpod/contracts  \
#         && cp `find . -name '*.wasm'` /home/gitpod/contracts  \
#         && cd /home/gitpod

# && rm -rf /home/gitpod/amax.contracts
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
RUN amcli wallet create --to-console | tail -n 1 | sed 's/"//g' >/password  \
        && amcli wallet import --private-key 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3
RUN echo '\n unlock-timeout = 31536000 \n' >$HOME/amax-wallet/config.ini
RUN rm -f $HOME/.wget-hsts
WORKDIR /home/gitpod
USER gitpod
RUN notOwnedFile=$(find . -not "(" -user gitpod -and -group gitpod ")" -print -quit)  \
        && { [ -z "$notOwnedFile" ] || { echo "Error: not all files/dirs in $HOME are owned by 'gitpod' user & group"; exit 1; } }
