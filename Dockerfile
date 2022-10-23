FROM debian:bullseye-slim AS unpacker
ARG TARGETARCH
RUN apt-get update \
    && apt-get install -y \
    sudo \
    tar \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*
COPY cache/arm-none-eabi_${TARGETARCH}.tar.xz /tmp/
COPY cache/cegcc_${TARGETARCH}.tar.xz /tmp/
WORKDIR /tmp
RUN XZ_OPT="-T0" tar xf /tmp/arm-none-eabi_${TARGETARCH}.tar.xz
RUN XZ_OPT="-T0" tar xf /tmp/cegcc_${TARGETARCH}.tar.xz

# builder
FROM debian:bullseye-slim
ARG USER_NAME="builder"
ARG USER_ID="1000"
ARG GROUP_ID="1000"
ARG TARGETARCH

RUN apt-get update \
    && apt-get install -y \
    sudo \
    build-essential \
    git \
    tar \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# add local user
RUN groupadd -g "${GROUP_ID}" "${USER_NAME}" && \
    useradd -l -u "${USER_ID}" -m "${USER_NAME}" -g "${USER_NAME}" -G sudo
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}/

# install toolchain
COPY --from=unpacker /tmp/arm-none-eabi /home/${USER_NAME}/arm-none-eabi
COPY --from=unpacker /tmp/cegcc /home/${USER_NAME}/cegcc

RUN echo 'export PATH=$PATH:$HOME/arm-none-eabi/bin' >> /home/${USER_NAME}/.bashrc
RUN echo 'export PATH=$PATH:$HOME/cegcc/bin' >> /home/${USER_NAME}/.bashrc

CMD ["/bin/bash"]
