ARG ARCH=

############################################
# build cross-tool-chain
FROM ${ARCH}debian:bullseye-slim

ARG USER_NAME="builder"
ARG USER_ID="1000"
ARG GROUP_ID="1000"

RUN apt-get update \
    && apt-get install -y \
    build-essential \
    git \
    autoconf \
    flex \
    texinfo \
    help2man \
    gawk \
    libtool-bin \
    libncurses-dev \
    bison \
    wget \
    unzip \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*
RUN wget http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.25.0.tar.bz2 \
    && tar xf crosstool-ng-1.25.0.tar.bz2 \
    && cd crosstool-ng-1.25.0 \
    && ./configure \
    && make -j \
    && make install

RUN groupadd -g "${GROUP_ID}" "${USER_NAME}" && \
    useradd -l -u "${USER_ID}" -m "${USER_NAME}" -g "${USER_NAME}"

USER ${USER_NAME}
WORKDIR /home/${USER_NAME}/

RUN mkdir ~/build
COPY files/ct-ng_dot_config_arm926ejs /home/${USER_NAME}/build/.config
RUN cd ~/build/ \
    && ls -la \
    && ct-ng build -j



############################################
# build cegcc
FROM ${ARCH}debian:bullseye-slim

ARG USER_NAME="builder"
ARG USER_ID="1000"
ARG GROUP_ID="1000"

RUN apt-get update \
    && apt-get install -y \
    build-essential \
    git \
    autoconf \
    flex \
    texinfo \
    help2man \
    gawk \
    libtool-bin \
    libncurses-dev \
    bison \
    wget \
    unzip \
    xz-utils \
    libmpfr-dev \
    libgmp-dev \
    libmpc-dev \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -g "${GROUP_ID}" "${USER_NAME}" && \
    useradd -l -u "${USER_ID}" -m "${USER_NAME}" -g "${USER_NAME}"
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}/

RUN cd ~/ \
    && git clone https://github.com/MaxKellermann/cegcc-build.git \
    && cd cegcc-build \
    && git submodule update --init \
    && mkdir ~/cegcc-output \
    && cd ~/cegcc-output \
    && ~/cegcc-build/build.sh --prefix=/home/${USER_NAME}/cegcc-toolchain --parallelism $(nproc)


############################################
# builder
FROM ${ARCH}debian:bullseye-slim
ARG USER_NAME="builder"
ARG USER_ID="1000"
ARG GROUP_ID="1000"

RUN apt-get update \
    && apt-get install -y \
    build-essential \
    git \
    xz-utils \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -g "${GROUP_ID}" "${USER_NAME}" && \
    useradd -l -u "${USER_ID}" -m "${USER_NAME}" -g "${USER_NAME}"
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}/

COPY --from=0 /home/${USER_NAME}/x-tools /home/${USER_NAME}/x-tools
COPY --from=1 /home/${USER_NAME}/cegcc-toolchain /home/${USER_NAME}/cegcc
RUN echo 'export PATH=$PATH:$HOME/x-tools/arm-none-eabi/bin' >> /home/${USER_NAME}/.bashrc
RUN echo 'export PATH=$PATH:$HOME/cegcc/bin' >> /home/${USER_NAME}/.bashrc
CMD ["/bin/bash"]
