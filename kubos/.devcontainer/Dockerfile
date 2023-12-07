FROM ubuntu:18.04

# install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libssl-dev \
    ninja-build libssl-dev pkg-config \
    git cmake curl gcc sqlite3 libsqlite3-dev wget ssh unzip \
    python3.7 python3.7-dev python3-pip python3-setuptools \
    doxygen graphviz plantuml \
    ncurses-dev bc rsync file libc6-i386-cross lib32stdc++6-x32-cross \
    sudo \
    && rm -rf /var/lib/apt/lists/* /var/cache/*

WORKDIR /tmp

# iOBC Toolchain
# RUN wget https://s3.amazonaws.com/kubos-world-readable-assets/iobc_toolchain.tar.gz \
#     && tar -xf iobc_toolchain.tar.gz -C /usr/bin \
#     && rm iobc_toolchain.tar.gz \
#     && echo "export PATH=$PATH:/usr/bin/iobc_toolchain/usr/bin" >> /etc/profile

# Beaglebone Black/Pumpkin MBM2 toolchain
# RUN wget https://s3.amazonaws.com/kubos-world-readable-assets/bbb_toolchain.tar.gz \
#     && tar -xf bbb_toolchain.tar.gz -C /usr/bin \
#     && rm bbb_toolchain.tar.gz

# copy config files
RUN git clone --depth 1 --single-branch --branch 1.20.0 https://github.com/kubos/kubos-vagrant \
    && mkdir -p /etc/minicom \
    && mkdir -p /etc/udev/rules.d \
    && mv kubos-vagrant/kubos-dev/bin/minirc.kubos /etc/minicom/minirc.kubos \
    && mv kubos-vagrant/kubos-dev/bin/kubos-usb.rules /etc/udev/rules.d/kubos-usb.rules

# create non-root user
RUN useradd --no-log-init --user-group --create-home --shell /bin/bash vagrant \
    && echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && chown -R vagrant /tmp/kubos-vagrant
USER vagrant

# install rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    # --default-toolchain 1.39.0 \
    --profile minimal \
    --component clippy \
    --component rustfmt \
    --component rust-analyzer \
    --component rust-src \
    --target arm-unknown-linux-gnueabihf \
    --target armv5te-unknown-linux-gnueabi \
    && $HOME/.cargo/bin/rustup default 1.39.0 \
    && mv /tmp/kubos-vagrant/kubos-dev/bin/cargo_config $HOME/.cargo/config.toml \
    && rm -rf /tmp/kubos-vagrant

# install python dependencies and modules
RUN python3.7 -m pip install --user --upgrade pip wheel setuptools \
    && git clone --depth 1 --single-branch --branch 1.20.0 https://github.com/kubos/kubos $HOME/.kubos/kubos \
    # fix toml dependency
    && find $HOME/.kubos/kubos -name 'requirements.txt' -exec sed -ie 's/toml==0.9.3.1/toml==0.9.6/g' {} + \
    && python3.7 -m pip install --user -r $HOME/.kubos/kubos/requirements.txt \
    && python3.7 -m pip install $HOME/.kubos/kubos/apis/app-api/python \
    && python3.7 -m pip install $HOME/.kubos/kubos/hal/python-hal/i2c \
    && python3.7 -m pip install $HOME/.kubos/kubos/libs/kubos-service \
    && python3.7 -m pip install cargo-zigbuild

# install kubos rust binaries
RUN $HOME/.cargo/bin/cargo install --git https://github.com/kubos/cargo-kubos \
    && $HOME/.cargo/bin/cargo install --locked --bin kubos-file-client --path $HOME/.kubos/kubos/clients/kubos-file-client/ \
    && $HOME/.cargo/bin/cargo install --locked --bin kubos-shell-client --path $HOME/.kubos/kubos/clients/kubos-shell-client/ \
    && $HOME/.cargo/bin/cargo install --locked --bin uart-comms-client --path $HOME/.kubos/kubos/clients/uart-comms-client/ \
    && rm -rf $HOME/.kubos/kubos/target \
    && $HOME/.cargo/bin/cargo +stable install --locked bacon

# aliases
RUN echo 'export PATH=$HOME/.local/bin:$PATH' >> $HOME/.bashrc \
    && echo 'alias python3=python3.7' >> $HOME/.bash_aliases \
    && echo '#!/bin/sh\n\n/usr/bin/python3.7 $@' >> $HOME/.local/bin/python3 \
    && chmod +x $HOME/.local/bin/python3 \
    # rustfmt and clippy components are not available for rust 1.39.0 aarch64
    # use rustfmt and clippy from the stable release instead
    && echo '#!/bin/sh\n\n$HOME/.cargo/bin/cargo-fmt +stable $@' >> $HOME/.local/bin/cargo-fmt \
    && chmod +x $HOME/.local/bin/cargo-fmt \
    && echo '#!/bin/sh\n\n$HOME/.cargo/bin/cargo-clippy +stable $@' >> $HOME/.local/bin/cargo-clippy \
    && chmod +x $HOME/.local/bin/cargo-clippy \
    && echo '#!/bin/sh\n\n$HOME/.cargo/bin/rustfmt +stable $@' >> $HOME/.local/bin/rustfmt \
    && chmod +x $HOME/.local/bin/rustfmt \
    && echo '#!/bin/sh\n\n$HOME/.cargo/bin/rust-analyzer +stable $@' >> $HOME/.local/bin/rust-analyzer \
    && chmod +x $HOME/.local/bin/rust-analyzer

WORKDIR /home/vagrant
