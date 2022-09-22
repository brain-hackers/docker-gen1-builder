UNAME_M := $(shell uname -m)
# Convert to the architecture name used by docker
ifeq (${UNAME_M}, aarch64)
ARCH := arm64
else ifeq (${UNAME_M}, arm64)
ARCH := arm64
else ifeq (${UNAME_M}, x86_64)
ARCH := amd64
else
$(error unsupported cpu architecture)
endif

all: build-image-local

show-host-arch:
	@echo ${ARCH}

build-worker: Dockerfile.worker
	docker build -t worker - < Dockerfile.worker

cache/cegcc_${ARCH}.tar.xz: scripts/build_cegcc.bash
	mkdir -p cache/
	chmod o+w cache/
	docker run -it --rm \
		-v ${PWD}:/work \
		worker \
		/bin/bash -c " \
			cd /work/ \
			&& ./scripts/build_cegcc.bash \
			&& mv ~/work/cegcc.tar.xz /work/cache/ \
		"
	mv cache/cegcc.tar.xz cache/cegcc_${ARCH}.tar.xz

cache/arm-none-eabi_${ARCH}.tar.xz: scripts/build_arm-none-eabi.bash
	mkdir -p cache/
	chmod o+w cache/
	docker run -it --rm \
		-v ${PWD}:/work \
		worker \
		/bin/bash -c " \
			cd /work/ \
			&& ./scripts/build_arm-none-eabi.bash \
			&& mv ~/work/x-tools/arm-none-eabi.tar.xz /work/cache/ \
		"
	mv cache/arm-none-eabi.tar.xz cache/arm-none-eabi_${ARCH}.tar.xz

build-image-local: cache/arm-none-eabi_${ARCH}.tar.xz cache/cegcc_${ARCH}.tar.xz
	docker build --tag brain-hackers/gen1_builder:latest .
