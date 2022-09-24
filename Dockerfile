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
    sudo \
    && rm -rf /var/lib/apt/lists/*

# add local user
RUN groupadd -g "${GROUP_ID}" "${USER_NAME}" && \
    useradd -l -u "${USER_ID}" -m "${USER_NAME}" -g "${USER_NAME}" -G sudo
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}/

# install toolchain
COPY cache/arm-none-eabi_${TARGETARCH}.tar.xz /home/${USER_NAME}/
COPY cache/cegcc_${TARGETARCH}.tar.xz /home/${USER_NAME}/
RUN tar xf /home/${USER_NAME}/arm-none-eabi_${TARGETARCH}.tar.xz
RUN tar xf /home/${USER_NAME}/cegcc_${TARGETARCH}.tar.xz
RUN echo 'export PATH=$PATH:$HOME/arm-none-eabi/bin' >> /home/${USER_NAME}/.bashrc
RUN echo 'export PATH=$PATH:$HOME/cegcc/bin' >> /home/${USER_NAME}/.bashrc

CMD ["/bin/bash"]
